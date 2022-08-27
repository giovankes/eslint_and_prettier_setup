# easy to install eslint and prettier config.

## i'd add an alias to your .zshrc with the following:
```bash
alias setup_eslint="exec 3<&1;bash <&3 <(curl  https://raw.githubusercontent.com/Giotje/eslint_and_prettier_setup/main/setup.sh 2> /dev/null)"
```

## this way it's super easy to execute by just typing `setup_eslint`.
