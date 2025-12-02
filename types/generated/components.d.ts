import type { Schema, Struct } from '@strapi/strapi';

export interface AboutSectionAboutSection extends Struct.ComponentSchema {
  collectionName: 'components_about_section_about_sections';
  info: {
    displayName: 'aboutSection';
    icon: 'bulletList';
  };
  attributes: {
    bigImage: Schema.Attribute.Media<'images'>;
    description: Schema.Attribute.Text;
    feature: Schema.Attribute.Component<'feature.feature', true>;
    smallImage: Schema.Attribute.Media<'images'>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface BannerBanner extends Struct.ComponentSchema {
  collectionName: 'components_banner_banners';
  info: {
    displayName: 'banner';
    icon: 'bulletList';
  };
  attributes: {
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface BusinessInfoCardBusinessInfoCard
  extends Struct.ComponentSchema {
  collectionName: 'components_business_info_card_business_info_cards';
  info: {
    displayName: 'businessInfoCard';
    icon: 'bulletList';
  };
  attributes: {
    description: Schema.Attribute.Text;
    icon: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    title: Schema.Attribute.String;
  };
}

export interface BusinessInfoBusinessInfo extends Struct.ComponentSchema {
  collectionName: 'components_business_info_business_infos';
  info: {
    displayName: 'businessInfo';
    icon: 'bulletList';
  };
  attributes: {
    bigImage: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    description: Schema.Attribute.String;
    missionCard: Schema.Attribute.Component<
      'business-info-card.business-info-card',
      false
    >;
    phoneNumber: Schema.Attribute.String;
    smallImage: Schema.Attribute.Media<
      'images' | 'files' | 'videos' | 'audios'
    >;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
    vissionCard: Schema.Attribute.Component<
      'business-info-card.business-info-card',
      false
    >;
  };
}

export interface DividerDivider extends Struct.ComponentSchema {
  collectionName: 'components_divider_dividers';
  info: {
    displayName: 'divider';
    icon: 'bulletList';
  };
  attributes: {
    title: Schema.Attribute.String;
  };
}

export interface FeatureFeature extends Struct.ComponentSchema {
  collectionName: 'components_feature_features';
  info: {
    displayName: 'feature';
    icon: 'bulletList';
  };
  attributes: {
    feature: Schema.Attribute.String;
  };
}

export interface HeroSectionHeroSection extends Struct.ComponentSchema {
  collectionName: 'components_hero_section_hero_sections';
  info: {
    displayName: 'heroSection';
    icon: 'bulletList';
  };
  attributes: {
    description: Schema.Attribute.Text;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface ServiceCardServiceCard extends Struct.ComponentSchema {
  collectionName: 'components_service_card_service_cards';
  info: {
    displayName: 'serviceCard';
    icon: 'bulletList';
  };
  attributes: {
    title: Schema.Attribute.String;
  };
}

export interface ServiceDataServiceData extends Struct.ComponentSchema {
  collectionName: 'components_service_data_service_data';
  info: {
    displayName: 'serviceData';
  };
  attributes: {
    descritpion: Schema.Attribute.Text;
    icon: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
  };
}

export interface ServicesSectionServicesSection extends Struct.ComponentSchema {
  collectionName: 'components_services_section_services_sections';
  info: {
    displayName: 'servicesSection';
    icon: 'bulletList';
  };
  attributes: {
    services: Schema.Attribute.Relation<'oneToMany', 'api::service.service'>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface SharedMedia extends Struct.ComponentSchema {
  collectionName: 'components_shared_media';
  info: {
    displayName: 'Media';
    icon: 'file-video';
  };
  attributes: {
    file: Schema.Attribute.Media<'images' | 'files' | 'videos'>;
  };
}

export interface SharedQuote extends Struct.ComponentSchema {
  collectionName: 'components_shared_quotes';
  info: {
    displayName: 'Quote';
    icon: 'indent';
  };
  attributes: {
    body: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

export interface SharedRichText extends Struct.ComponentSchema {
  collectionName: 'components_shared_rich_texts';
  info: {
    description: '';
    displayName: 'Rich text';
    icon: 'align-justify';
  };
  attributes: {
    body: Schema.Attribute.RichText;
  };
}

export interface SharedSeo extends Struct.ComponentSchema {
  collectionName: 'components_shared_seos';
  info: {
    description: '';
    displayName: 'Seo';
    icon: 'allergies';
    name: 'Seo';
  };
  attributes: {
    metaDescription: Schema.Attribute.Text & Schema.Attribute.Required;
    metaTitle: Schema.Attribute.String & Schema.Attribute.Required;
    shareImage: Schema.Attribute.Media<'images'>;
  };
}

export interface SharedSlider extends Struct.ComponentSchema {
  collectionName: 'components_shared_sliders';
  info: {
    description: '';
    displayName: 'Slider';
    icon: 'address-book';
  };
  attributes: {
    files: Schema.Attribute.Media<'images', true>;
  };
}

export interface WhereWeOperateWhereWeOperate extends Struct.ComponentSchema {
  collectionName: 'components_where_we_operate_where_we_operates';
  info: {
    displayName: 'whereWeOperate';
    icon: 'bulletList';
  };
  attributes: {
    countries: Schema.Attribute.Component<'feature.feature', true>;
    description: Schema.Attribute.String;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    title: Schema.Attribute.String;
  };
}

export interface WhyUsWhyUs extends Struct.ComponentSchema {
  collectionName: 'components_why_us_whyuses';
  info: {
    displayName: 'whyUs';
    icon: 'bulletList';
  };
  attributes: {
    features: Schema.Attribute.Component<'feature.feature', true>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'about-section.about-section': AboutSectionAboutSection;
      'banner.banner': BannerBanner;
      'business-info-card.business-info-card': BusinessInfoCardBusinessInfoCard;
      'business-info.business-info': BusinessInfoBusinessInfo;
      'divider.divider': DividerDivider;
      'feature.feature': FeatureFeature;
      'hero-section.hero-section': HeroSectionHeroSection;
      'service-card.service-card': ServiceCardServiceCard;
      'service-data.service-data': ServiceDataServiceData;
      'services-section.services-section': ServicesSectionServicesSection;
      'shared.media': SharedMedia;
      'shared.quote': SharedQuote;
      'shared.rich-text': SharedRichText;
      'shared.seo': SharedSeo;
      'shared.slider': SharedSlider;
      'where-we-operate.where-we-operate': WhereWeOperateWhereWeOperate;
      'why-us.why-us': WhyUsWhyUs;
    }
  }
}
