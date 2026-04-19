import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint, SignInPageProps } from '@backstage/plugin-app-react';
import { SignInPage } from '@backstage/core-components';
import { microsoftAuthApiRef } from '@backstage/core-plugin-api';
import React from 'react';

const microsoftSignInPage = SignInPageBlueprint.make({
  params: {
    loader: async () => (props: any) => (
      <SignInPage
        {...props}
        auto
        provider={{
          id: 'microsoft',
          title: 'Microsoft',
          message: 'Sign in to Mercedes-Benz IDP',
          apiRef: microsoftAuthApiRef,
        }}
      />
    ),
  },
});

export const authModule = createFrontendModule({
  pluginId: 'app',
  extensions: [microsoftSignInPage],
});
