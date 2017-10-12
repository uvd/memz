# MEMZ web

## Deployment

**Note**: Make sure your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are exported.

Deployment defaults to testing. So you can just run:
```
make deploy
```

To deploy to production:
```
ENV=production; DOMAIN=memz.uvd.co.uk; make deploy
```
