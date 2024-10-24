// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

import {themes as prismThemes} from 'prism-react-renderer';

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: 'Memorize Scripture',
  tagline: 'Helping you learn Bible verses by heart',
  favicon: 'img/favicon.ico',
  url: 'https://ethnos.dev',
  baseUrl: '/apps/memorize-scripture/tutorial',

  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: 'ethnosdev', // Usually your GitHub org/user name.
  projectName: 'ethnosdev.github.io', // Usually your repo name.

  onBrokenLinks: 'throw',
  onBrokenMarkdownLinks: 'warn',

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          routeBasePath: '/',
          sidebarPath: require.resolve('./sidebars.js'),
        },
        blog: false,
        theme: {
          customCss: require.resolve('./src/css/custom.css'),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({
      // Replace with your project's social card
      image: 'img/social-card.jpg',
      navbar: {
        title: 'Memorize Scripture',
        logo: {
          alt: 'Logo',
          src: 'img/logo.png',
        },
        items: [
          {
            href: 'https://github.com/ethnosdev/memorize_scripture',
            position: 'right',
            className: 'header-github-link',
            "aria-label": "GitHub repository",
          },
        ]
      },
      footer: {
        style: 'dark',
        links: [],
        copyright: `${new Date().getFullYear()} EthnosDev LLC`,
      },
      prism: {
        theme: prismThemes.github,
        darkTheme: prismThemes.dracula,
      },
    }),
};

module.exports = config;
