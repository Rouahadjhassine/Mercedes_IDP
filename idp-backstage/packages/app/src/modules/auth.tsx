import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { SignInPageBlueprint, SignInPageProps } from '@backstage/plugin-app-react';
import { useApi, microsoftAuthApiRef } from '@backstage/core-plugin-api';
import { UserIdentity } from '@backstage/core-components';

import { useState } from 'react';
import { makeStyles, Button, Typography, CircularProgress } from '@material-ui/core';

const useStyles = makeStyles({
  container: {
    display: 'flex',
    height: '100vh',
    width: '100vw',
    backgroundImage: 'url(/login-bg.png)',
    backgroundSize: 'cover',
    backgroundPosition: 'center',
    alignItems: 'center',
    justifyContent: 'center',
    fontFamily: '"Inter", "Roboto", sans-serif',
    margin: 0,
    padding: 0,
  },
  glassCard: {
    background: 'rgba(15, 23, 42, 0.7)',
    backdropFilter: 'blur(20px)',
    border: '1px solid rgba(255, 255, 255, 0.1)',
    borderRadius: '24px',
    padding: '48px',
    maxWidth: '450px',
    width: '90%',
    textAlign: 'center',
    boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5), inset 0 1px 0 0 rgba(255,255,255,0.1)',
    color: '#ffffff',
  },
  title: {
    fontWeight: 800,
    fontSize: '32px',
    marginBottom: '12px',
    background: 'linear-gradient(135deg, #e0e7ff 0%, #3b82f6 100%)',
    WebkitBackgroundClip: 'text',
    WebkitTextFillColor: 'transparent',
    letterSpacing: '-0.5px',
  },
  subtitle: {
    fontSize: '15px',
    color: '#94a3b8',
    marginBottom: '40px',
    lineHeight: 1.6,
  },
  button: {
    background: 'linear-gradient(to right, #2563eb, #3b82f6)',
    color: '#ffffff',
    borderRadius: '12px',
    padding: '14px 24px',
    textTransform: 'none',
    fontWeight: 600,
    fontSize: '16px',
    width: '100%',
    boxShadow: '0 10px 15px -3px rgba(37, 99, 235, 0.3)',
    transition: 'all 0.3s ease',
    '&:hover': {
      background: 'linear-gradient(to right, #1d4ed8, #2563eb)',
      boxShadow: '0 20px 25px -5px rgba(37, 99, 235, 0.5)',
      transform: 'translateY(-2px)',
    },
  },
  icon: {
    fontSize: '48px',
    marginBottom: '20px',
    color: '#60a5fa',
  }
});

const CustomSignInPage = ({ onSignInSuccess }: SignInPageProps) => {
  const classes = useStyles();
  const authApi = useApi(microsoftAuthApiRef);
  const [loading, setLoading] = useState(false);

  const handleSignIn = async () => {
    setLoading(true);
    try {
      const identityResponse = await authApi.getBackstageIdentity({
        optional: false,
      });
      const profile = await authApi.getProfile();

      let identity = identityResponse?.identity;

      if (!identity || !identity.userEntityRef) {
        identity = {
          type: 'user',
          userEntityRef: 'user:default/guest',
          ownershipEntityRefs: ['user:default/guest'],
        };
      }

      if (!identity.ownershipEntityRefs) {
        identity.ownershipEntityRefs = [identity.userEntityRef];
      }

      identity.ownershipEntityRefs = identity.ownershipEntityRefs.filter(Boolean);

      const identityApi = UserIdentity.create({
        identity,
        authApi,
        profile,
      });

      onSignInSuccess(identityApi);
    } catch (error) {
      console.error('Sign-in failed', error);
      setLoading(false);
    }
  };

  return (
    <div className={classes.container}>
      <div className={classes.glassCard}>
        <svg className={classes.icon} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: 64, height: 64 }}>
          <path d="M12 2L2 7l10 5 10-5-10-5z" />
          <path d="M2 17l10 5 10-5" />
          <path d="M2 12l10 5 10-5" />
        </svg>
        <Typography variant="h4" className={classes.title}>
          NTT DATA Platform
        </Typography>
        <Typography variant="body1" className={classes.subtitle}>
          Secure Infrastructure Management for Mercedes-Benz. <br/>Powered by Terraform Azure.
        </Typography>
        
        <Button 
          className={classes.button} 
          onClick={handleSignIn}
          disabled={loading}
        >
          {loading ? <CircularProgress size={24} color="inherit" /> : 'Sign in with Microsoft'}
        </Button>
      </div>
    </div>
  );
};

const customSignInPageBlueprint = SignInPageBlueprint.make({
  params: {
    loader: async () => (props: any) => <CustomSignInPage {...props} />,
  },
});

export const authModule = createFrontendModule({
  pluginId: 'app',
  extensions: [customSignInPageBlueprint],
});
