import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

backend.add(import('@backstage/plugin-app-backend'));
backend.add(import('@backstage/plugin-proxy-backend'));

// scaffolder plugin
backend.add(import('@backstage/plugin-scaffolder-backend'));
backend.add(import('@backstage/plugin-scaffolder-backend-module-github'));
backend.add(import('@backstage/plugin-scaffolder-backend-module-azure'));
backend.add(
  import('@backstage/plugin-scaffolder-backend-module-notifications'),
);
backend.add(import('./actions/ado-pipeline'));

// techdocs plugin
backend.add(import('@backstage/plugin-techdocs-backend'));

// auth plugin
backend.add(import('@backstage/plugin-auth-backend'));
backend.add(import('@backstage/plugin-auth-backend-module-guest-provider'));

import { createBackendModule } from '@backstage/backend-plugin-api';
import { authProvidersExtensionPoint, createOAuthProviderFactory, createOAuthAuthenticator } from '@backstage/plugin-auth-node';
import { microsoftAuthenticator } from '@backstage/plugin-auth-backend-module-microsoft-provider';

// Wraps microsoftAuthenticator to inject prompt=select_account into
// every authorization URL → forces Azure AD to always show the account picker
const microsoftAuthenticatorWithPrompt = createOAuthAuthenticator({
  ...microsoftAuthenticator,
  async start(input, ctx) {
    const result = await microsoftAuthenticator.start(input, ctx);
    // Inject prompt=select_account into the redirect URL
    const url = new URL(result.url);
    url.searchParams.set('prompt', 'select_account');
    return { ...result, url: url.toString() };
  },
});

const customAuth = createBackendModule({
  pluginId: 'auth',
  moduleId: 'custom-auth-provider',
  register(reg) {
    reg.registerInit({
      deps: { providers: authProvidersExtensionPoint },
      async init({ providers }) {
        providers.registerProvider({
          providerId: 'microsoft',
          factory: createOAuthProviderFactory({
            authenticator: microsoftAuthenticatorWithPrompt,
            async signInResolver(info, ctx) {
              const { profile } = info;
              const email = profile.email;
              if (!email) {
                throw new Error('User profile contained no email');
              }
              // Generate a safe entity name from the email (e.g., firstname-lastname)
              const name = email.split('@')[0].replace(/[^a-zA-Z0-9]/g, '-');
              const userEntityRef = `user:default/${name}`;
              
              // Issue token without validating against catalog
              return ctx.issueToken({
                claims: {
                  sub: userEntityRef,
                  ent: [userEntityRef],
                },
              });
            },
          }),
        });
      },
    });
  },
});

backend.add(customAuth);

// permission plugin
backend.add(import('@backstage/plugin-permission-backend'));
backend.add(
  import('@backstage/plugin-permission-backend-module-allow-all-policy'),
);

// search plugin
backend.add(import('@backstage/plugin-search-backend'));
backend.add(import('@backstage/plugin-search-backend-module-catalog'));
backend.add(import('@backstage/plugin-search-backend-module-techdocs'));

// catalog plugin
backend.add(import('@backstage/plugin-catalog-backend'));
backend.add(
  import('@backstage/plugin-catalog-backend-module-scaffolder-entity-model'),
);

backend.add(import('@backstage/plugin-catalog-backend-module-logs'));
backend.add(import('@backstage/plugin-catalog-backend-module-msgraph'));

backend.start();


