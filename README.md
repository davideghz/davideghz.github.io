# My personal website
Powered by Middleman and hosted on GitHub Pages.

Source code is available in `source` branch.

Live (generated) code is available in `master` branch.


## Run server locally
```
middleman server
```

## Build static files
```
middleman build
```

## First time cloning the repo
```
cd build
git remote add origin git@github.com:davideghz/davideghz.github.io.git
git add .
git commit m 'first commit'
git push origin master --force
```

## Deploy
```
cd build
git checkout master
git push origin master
```