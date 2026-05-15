import { createFrontendModule } from '@backstage/frontend-plugin-api';
import { ThemeBlueprint } from '@backstage/plugin-app-react';
import { themes, UnifiedThemeProvider, createUnifiedTheme, genPageTheme } from '@backstage/theme';
import { ThemeProvider, createTheme } from '@material-ui/core/styles';
import CssBaseline from '@material-ui/core/CssBaseline';

import * as React from 'react';

// Get the base v4 theme from Backstage's dark theme
const baseDarkTheme = themes.dark.getTheme('v4') as any;

const customTheme = createTheme({
  ...baseDarkTheme,
  palette: {
    ...baseDarkTheme.palette,
    primary: {
      ...baseDarkTheme.palette.primary,
      main: '#3b82f6', // NTT Data Blue
    },
    background: {
      default: '#020617', // Very deep slate, matching login
      paper: '#0f172a', // Card background
    },
  },
  typography: {
    ...baseDarkTheme.typography,
    fontFamily: '"Inter", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: { ...baseDarkTheme.typography?.h1, fontWeight: 700, background: 'linear-gradient(135deg, #e0e7ff 0%, #3b82f6 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' },
    h2: { ...baseDarkTheme.typography?.h2, fontWeight: 700 },
    h3: { ...baseDarkTheme.typography?.h3, fontWeight: 600 },
    h4: { ...baseDarkTheme.typography?.h4, fontWeight: 600 },
  },
  overrides: {
    ...baseDarkTheme.overrides,
    MuiButton: {
      ...baseDarkTheme.overrides?.MuiButton,
      containedPrimary: {
        background: 'linear-gradient(to right, #2563eb, #3b82f6)',
        color: '#ffffff',
        border: 0,
        borderRadius: '8px',
        boxShadow: '0 4px 6px -1px rgba(37, 99, 235, 0.3)',
        '&:hover': {
          background: 'linear-gradient(to right, #1d4ed8, #2563eb)',
          boxShadow: '0 10px 15px -3px rgba(37, 99, 235, 0.4)',
        },
      },
      root: {
        borderRadius: '8px',
        textTransform: 'none',
        fontWeight: 600,
      }
    },
    MuiCard: {
      ...baseDarkTheme.overrides?.MuiCard,
      root: {
        background: 'rgba(15, 23, 42, 0.7)',
        backdropFilter: 'blur(16px)',
        border: '1px solid rgba(255, 255, 255, 0.05)',
        borderRadius: '16px',
        boxShadow: '0 10px 15px -3px rgba(0, 0, 0, 0.3)',
      }
    },
    MuiDrawer: {
      ...baseDarkTheme.overrides?.MuiDrawer,
      paper: {
        background: '#020617', // Sidebar matches the deep background
        borderRight: '1px solid rgba(255,255,255,0.05)',
      }
    },
    MuiStepIcon: {
      ...baseDarkTheme.overrides?.MuiStepIcon,
      root: {
        color: '#1e293b',
        '&$active': {
          color: '#3b82f6',
        },
        '&$completed': {
          color: '#10b981',
        }
      }
    }
  }
});

// Custom Page Theme to remove the green bar and use NTT Data colors
const nttDataPageTheme = genPageTheme({
  colors: ['#0f172a', '#3b82f6'],
  shape: 'wave',
});

const customUnifiedTheme = createUnifiedTheme({
  palette: baseDarkTheme.palette,
  typography: baseDarkTheme.typography,
  defaultPageTheme: 'home',
  pageTheme: {
    home: nttDataPageTheme,
    documentation: nttDataPageTheme,
    tool: nttDataPageTheme,
    service: nttDataPageTheme,
    website: nttDataPageTheme,
    library: nttDataPageTheme,
    other: nttDataPageTheme,
    app: nttDataPageTheme,
  },
});

const nttMercedesTheme = ThemeBlueprint.make({
  name: 'ntt-mercedes',
  params: {
    theme: {
      id: 'ntt-mercedes',
      title: 'NTT Mercedes Dark',
      variant: 'dark',
      Provider: ({ children }: { children: React.ReactNode }) => (
        <UnifiedThemeProvider theme={customUnifiedTheme}>
          <ThemeProvider theme={customTheme}>
            <CssBaseline />
            {children}
          </ThemeProvider>
        </UnifiedThemeProvider>
      ),
    },
  },
});

export const themeModule = createFrontendModule({
  pluginId: 'app',
  extensions: [nttMercedesTheme],
});
