import { makeStyles } from '@material-ui/core';


const useStyles = makeStyles({
  container: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    width: 40,
    height: 40,
    fontFamily: '"Inter", "Roboto", sans-serif',
    background: 'linear-gradient(135deg, #2563eb 0%, #3b82f6 100%)',
    borderRadius: '8px',
  },
  textNTT: {
    fontWeight: 800,
    fontSize: '14px',
    color: '#ffffff',
  }
});

export const LogoIcon = () => {
  const classes = useStyles();
  return (
    <div className={classes.container}>
      <span className={classes.textNTT}>NTT</span>
    </div>
  );
};
