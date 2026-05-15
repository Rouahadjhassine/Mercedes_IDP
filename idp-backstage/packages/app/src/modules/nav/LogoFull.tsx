import { makeStyles } from '@material-ui/core';


const useStyles = makeStyles({
  container: {
    display: 'flex',
    alignItems: 'center',
    height: 40,
    fontFamily: '"Inter", "Roboto", sans-serif',
  },
  textNTT: {
    fontWeight: 800,
    fontSize: '20px',
    color: '#ffffff',
    marginRight: '8px',
  },
  textData: {
    fontWeight: 400,
    fontSize: '20px',
    color: '#3b82f6',
    marginRight: '8px',
  },
  divider: {
    width: '1px',
    height: '24px',
    backgroundColor: 'rgba(255,255,255,0.2)',
    marginRight: '8px',
  },
  textMercedes: {
    fontWeight: 600,
    fontSize: '14px',
    color: '#94a3b8',
    letterSpacing: '0.5px',
    textTransform: 'uppercase',
  }
});

export const LogoFull = () => {
  const classes = useStyles();
  return (
    <div className={classes.container}>
      <span className={classes.textNTT}>NTT</span>
      <span className={classes.textData}>DATA</span>
      <div className={classes.divider} />
      <span className={classes.textMercedes}>Mercedes-Benz</span>
    </div>
  );
};
