module.exports = {
  apps: [
    {
      name: 'strapi',
      script: 'npm',
      args: 'start',
      cwd: './',
      instances: 1,
      // Uncomment below to enable cluster mode (multiple instances)
      // instances: 'max', // or specify a number
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        PORT: 1337,
      },
      // Environment variables from .env file will be loaded automatically
      // You can also specify them here if needed
      error_file: './logs/err.log',
      out_file: './logs/out.log',
      log_file: './logs/combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10,
      restart_delay: 4000,
      // Graceful shutdown
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 10000,
    },
  ],
};

