#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { randomUUID } = require('crypto');

const rootDir = path.resolve(__dirname, '..');
const apiDir = path.join(rootDir, 'src', 'api');
const componentsDir = path.join(rootDir, 'src', 'components');
const outputPath = path.join(rootDir, 'postman_collection.json');

function readJSON(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function collectContentTypes() {
  if (!fs.existsSync(apiDir)) {
    throw new Error(`Missing Strapi api directory at ${apiDir}`);
  }

  const apis = fs
    .readdirSync(apiDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory());

  const contentTypes = [];

  apis.forEach((apiEntry) => {
    const contentTypesDir = path.join(apiDir, apiEntry.name, 'content-types');
    if (!fs.existsSync(contentTypesDir)) {
      return;
    }

    fs.readdirSync(contentTypesDir, { withFileTypes: true })
      .filter((entry) => entry.isDirectory())
      .forEach((ctEntry) => {
        const schemaPath = path.join(contentTypesDir, ctEntry.name, 'schema.json');
        if (!fs.existsSync(schemaPath)) {
          return;
        }
        const schema = readJSON(schemaPath);
        contentTypes.push({
          api: apiEntry.name,
          name: ctEntry.name,
          schema,
        });
      });
  });

  return contentTypes.sort((a, b) => {
    const nameA = (a.schema.info?.displayName || a.schema.info?.singularName || a.name || '').toLowerCase();
    const nameB = (b.schema.info?.displayName || b.schema.info?.singularName || b.name || '').toLowerCase();
    return nameA.localeCompare(nameB);
  });
}

function collectComponents() {
  if (!fs.existsSync(componentsDir)) {
    return {};
  }

  const components = {};

  function walk(dir, segments = []) {
    fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
      const entryPath = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        walk(entryPath, [...segments, entry.name]);
      } else if (entry.isFile() && entry.name.endsWith('.json')) {
        const componentName = entry.name.replace(/\.json$/, '');
        const uid = [...segments, componentName].join('.');
        components[uid] = readJSON(entryPath);
      }
    });
  }

  walk(componentsDir);
  return components;
}

function titleize(value = '') {
  return value
    .split(/[-_\s]/)
    .filter(Boolean)
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function exampleFromAttributes(attributes = {}, components, depth = 0) {
  return Object.fromEntries(
    Object.entries(attributes).map(([name, attr]) => [name, exampleForAttribute(name, attr, components, depth)])
  );
}

function exampleForAttribute(name, attr, components, depth) {
  if (!attr || depth > 4) {
    return null;
  }

  const label = titleize(name || 'field');

  switch (attr.type) {
    case 'string':
    case 'text':
    case 'richtext':
      return attr.default ?? `${label} value`;
    case 'email':
      return 'user@example.com';
    case 'password':
      return 'P@ssw0rd123';
    case 'uid':
      return `${(attr.targetField && `${attr.targetField}-`) || ''}sample-${name}`;
    case 'integer':
    case 'biginteger':
      return 0;
    case 'float':
    case 'decimal':
      return 0.0;
    case 'boolean':
      return false;
    case 'json':
      return {};
    case 'enumeration':
      return attr.enum?.[0] ?? `${label} option`;
    case 'date':
      return '2024-01-01';
    case 'datetime':
    case 'timestamp':
      return '2024-01-01T00:00:00.000Z';
    case 'time':
      return '12:00:00.000';
    case 'media':
      return attr.multiple ? [1] : 1;
    case 'relation':
      return relationExample(attr.relation);
    case 'component':
      return componentExample(attr, components, depth + 1);
    case 'dynamiczone':
      return dynamicZoneExample(attr, components, depth + 1);
    default:
      return attr.default ?? `${label} value`;
  }
}

function relationExample(relationType = '') {
  switch (relationType) {
    case 'oneToOne':
    case 'manyToOne':
      return 1;
    case 'oneToMany':
    case 'manyToMany':
      return [1];
    default:
      return null;
  }
}

function componentExample(attr, components, depth) {
  const componentSchema = components[attr.component];
  if (!componentSchema) {
    return attr.repeatable ? [] : {};
  }

  const value = exampleFromAttributes(componentSchema.attributes, components, depth);
  return attr.repeatable ? [value] : value;
}

function dynamicZoneExample(attr, components, depth) {
  const [firstComponent] = attr.components || [];
  if (!firstComponent) {
    return [];
  }

  const componentSchema = components[firstComponent];
  const value = componentSchema ? exampleFromAttributes(componentSchema.attributes, components, depth) : {};
  return [{ __component: firstComponent, ...value }];
}

function buildUrl(segments) {
  const pathSegments = ['api', ...segments];
  return {
    raw: `{{baseUrl}}/${pathSegments.join('/')}`,
    host: ['{{baseUrl}}'],
    path: pathSegments,
  };
}

function createRequest({ name, method, urlSegments, description, body }) {
  const request = {
    name,
    request: {
      method,
      header: [],
      url: buildUrl(urlSegments),
      description,
    },
  };

  if (body) {
    request.request.header = [
      {
        key: 'Content-Type',
        value: 'application/json',
      },
    ];
    request.request.body = {
      mode: 'raw',
      raw: body,
      options: {
        raw: {
          language: 'json',
        },
      },
    };
  }

  return request;
}

function collectionRequests(contentType, components) {
  const { schema } = contentType;
  const displayName = schema.info?.displayName || titleize(schema.info?.singularName || contentType.name);
  const slug = schema.info?.pluralName || `${schema.info?.singularName || contentType.name}s`;
  const exampleData = { data: exampleFromAttributes(schema.attributes, components) };
  const body = JSON.stringify(exampleData, null, 2);

  return {
    name: displayName,
    item: [
      createRequest({
        name: `List ${displayName}`,
        method: 'GET',
        urlSegments: [slug],
        description: `Retrieve a paginated list of ${displayName}.`,
      }),
      createRequest({
        name: `Get ${displayName} by ID`,
        method: 'GET',
        urlSegments: [slug, '{{id}}'],
        description: `Retrieve a single ${displayName} entry by ID.`,
      }),
      createRequest({
        name: `Create ${displayName}`,
        method: 'POST',
        urlSegments: [slug],
        description: `Create a new ${displayName} entry.`,
        body,
      }),
      createRequest({
        name: `Update ${displayName}`,
        method: 'PUT',
        urlSegments: [slug, '{{id}}'],
        description: `Update an existing ${displayName} entry.`,
        body,
      }),
      createRequest({
        name: `Delete ${displayName}`,
        method: 'DELETE',
        urlSegments: [slug, '{{id}}'],
        description: `Delete an existing ${displayName} entry.`,
      }),
    ],
  };
}

function singleTypeRequests(contentType, components) {
  const { schema } = contentType;
  const displayName = schema.info?.displayName || titleize(schema.info?.singularName || contentType.name);
  const slug = schema.info?.singularName || contentType.name;
  const exampleData = { data: exampleFromAttributes(schema.attributes, components) };
  const body = JSON.stringify(exampleData, null, 2);

  return {
    name: displayName,
    item: [
      createRequest({
        name: `Get ${displayName}`,
        method: 'GET',
        urlSegments: [slug],
        description: `Retrieve the ${displayName} single type.`,
      }),
      createRequest({
        name: `Update ${displayName}`,
        method: 'PUT',
        urlSegments: [slug],
        description: `Update the ${displayName} single type.`,
        body,
      }),
    ],
  };
}

function buildCollection(contentTypes, components) {
  const collectionFolder = { name: 'Collection Types', item: [] };
  const singleFolder = { name: 'Single Types', item: [] };

  contentTypes.forEach((contentType) => {
    if (contentType.schema.kind === 'singleType') {
      singleFolder.item.push(singleTypeRequests(contentType, components));
    } else {
      collectionFolder.item.push(collectionRequests(contentType, components));
    }
  });

  const folders = [];
  if (collectionFolder.item.length) {
    folders.push(collectionFolder);
  }
  if (singleFolder.item.length) {
    folders.push(singleFolder);
  }

  return {
    info: {
      _postman_id: randomUUID(),
      name: 'Strapi Content API',
      description: 'Automatically generated Postman collection based on local Strapi schemas.',
      schema: 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    },
    item: folders,
    variable: [
      {
        key: 'baseUrl',
        value: 'http://localhost:1337',
        type: 'string',
      },
    ],
  };
}

function main() {
  try {
    const components = collectComponents();
    const contentTypes = collectContentTypes();
    if (!contentTypes.length) {
      throw new Error('No Strapi content types were found.');
    }

    const collection = buildCollection(contentTypes, components);
    fs.writeFileSync(outputPath, JSON.stringify(collection, null, 2));
    console.log(`Postman collection saved to ${outputPath}`);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
}

main();

