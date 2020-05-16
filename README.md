# httprouter-example

Example of using [httprouter](https://github.com/julienschmidt/httprouter)
with [zerolog](https://github.com/rs/zerolog)
and gorilla middleware [handlers](https://github.com/gorilla/handlers)

## Quick start

Clone the repos (outside your GOPATH since this is a module)

    git clone https://github.com/mozey/httprouter-example.git
    
    cd httprouter-example

Following the 12 factor app recommendation to
[store config in the environment](https://12factor.net/config).
Configuration is done using [environment variables](https://en.wikipedia.org/wiki/Environment_variable)

The scripts use [bash](https://www.gnu.org/software/bash/),
[make](https://www.gnu.org/software/make/),
[fswatch](https://github.com/emcrisostomo/fswatch)

Copy script to export dev config

    cp sample.dev.sh dev.sh 

Run dev server (no live reload)

    ./dev.sh app.restart
    
Run dev server with live reload
    
    ./dev.sh app
   
    
**Alternatively**,
use [mozey/config](https://github.com/mozey/config)
to manage env with a flat config.json file.
First setup a helper func for [toggling env](https://github.com/mozey/config#toggling-env).
Then run the commands below
    
    APP_DIR=$(pwd) ./scripts/config.sh
    
    conf dev && make app
    
...or using [tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux)

    cp sample.up.sh up.sh
    
    ./up.sh
    
    ./tmux.sh app
    # ctrl+b d
    
    cp sample.down.sh down.sh
    
    ./down.sh
    
## Reset

Removes all user config

    APP_DIR=$(pwd) ./scripts/reset.sh
    
    
## Examples
  
Token is required by default    
http://localhost:8118/token/is/required/by/default

Static content skips the token check
- http://localhost:8118/index.html
- http://localhost:8118
- http://localhost:8118/www/data/go.txt
    
http://localhost:8118/hello/foo?token=123
    
http://localhost:8118/api?token=123
    
http://localhost:8118/panic
    
http://localhost:8118/does/not/exist?token=123
    
TODO
http://localhost:8118/proxy
    
Tip: make requests from the cli with [httpie](https://httpie.org/)



