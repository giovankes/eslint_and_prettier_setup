#!/bin/bash

# ----------------------
# Color Variables
# ----------------------
RED="\033[0;31m"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

# --------------------------------------
# Prompts for configuration preferences
# --------------------------------------

# Package Manager Prompt
echo
echo "Which package manager are you using?"
select package_command_choices in "Yarn" "npm" "Cancel"; do
  case $package_command_choices in
    Yarn ) pkg_cmd='yarn add'; break;;
    npm ) pkg_cmd='npm install'; break;;
    Cancel ) exit;;
  esac
done
echo

# File Format Prompt
echo "Which ESLint and Prettier configuration format do you prefer?"
select config_extension in ".js" ".json" "Cancel"; do
  case $config_extension in
    .js ) config_opening='module.exports = {'; break;;
    .json ) config_opening='{'; break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing eslintrc files
if [ -f ".eslintrc.js" -o -f ".eslintrc.yaml" -o -f ".eslintrc.yml" -o -f ".eslintrc.json" -o -f ".eslintrc" ]; then
  echo -e "${RED}Existing ESLint config file(s) found:${NC}"
  ls -a .eslint* | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} there is loading priority when more than one config file is present: https://eslint.org/docs/user-guide/configuring#configuration-file-formats"
  echo
  read -p  "Write .eslintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping ESLint config${NC}"
    skip_eslint_setup="true"
  fi
fi
finished=false

# Max Line Length Prompt
while ! $finished; do
  read -p "What max line length do you want to set for ESLint and Prettier? (Recommendation: 80)"
  if [[ $REPLY =~ ^[0-9]{2,3}$ ]]; then
    max_len_val=$REPLY
    finished=true
    echo
  else
    echo -e "${YELLOW}Please choose a max length of two or three digits, e.g. 80 or 100 or 120${NC}"
  fi
done

# Trailing Commas Prompt
echo "What style of trailing commas do you want to enforce with Prettier?"
echo -e "${YELLOW}>>>>> See https://prettier.io/docs/en/options.html#trailing-commas for more details.${NC}"
select trailing_comma_pref in "none" "es5" "all"; do
  case $trailing_comma_pref in
    none ) break;;
    es5 ) break;;
    all ) break;;
  esac
done
echo

# Checks for existing prettierrc files
if [ -f ".prettierrc.js" -o -f "prettier.config.js" -o -f ".prettierrc.yaml" -o -f ".prettierrc.yml" -o -f ".prettierrc.json" -o -f ".prettierrc.toml" -o -f ".prettierrc" ]; then
  echo -e "${RED}Existing Prettier config file(s) found${NC}"
  ls -a | grep "prettier*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://prettier.io/docs/en/configuration.html"
  echo
  read -p  "Write .prettierrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Prettier config${NC}"
    skip_prettier_setup="true"
  fi
  echo
fi

# ----------------------
# Perform Configuration
# ----------------------
echo
echo -e "${GREEN}Configuring your development environment... ${NC}"

echo
echo -e "1/5 ${LCYAN}ESLint & Prettier Installation... ${NC}"
echo
$pkg_cmd -D eslint prettier

echo
echo -e "2/5 ${YELLOW}Conforming to Airbnb's JavaScript Style Guide... ${NC}"
echo
$pkg_cmd -D eslint-config-airbnb eslint-plugin-jsx-a11y eslint-plugin-import eslint-plugin-react babel-eslint

echo
echo -e "3/5 ${LCYAN}Making ESlint and Prettier play nice with each other... ${NC}"
echo "See https://github.com/prettier/eslint-config-prettier for more details."
echo
$pkg_cmd -D eslint-config-prettier eslint-plugin-prettier


if [ "$skip_eslint_setup" == "true" ]; then
  break
else
  echo
  echo -e "4/5 ${YELLOW}Building your .eslintrc${config_extension} file...${NC}"
  > ".eslintrc${config_extension}" # truncates existing file (or creates empty)

  echo ${config_opening}'
  {
  "env": {
    "browser": true,
    "node": true,
    "jest": true
  },
  "extends": [
    "plugin:jsx-a11y/recommended",
    "eslint:recommended",
    "next/core-web-vitals",
    "prettier"
  ],
  "root": true,
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "allowImportExportEverywhere": true,
    "sourceType": "module"
  },
  "plugins": ["react", "jsx-a11y", "import"],
  "rules": {
    "camelcase": [
      "off",
      {
        "ignoreDestructuring": true,
        "allow": ["UNSAFE_componentWillMount"]
      }
    ],
    "comma-dangle": "off",
    "eqeqeq": "off",
    "global-require": 0,
    "linebreak-style": ["error", "unix"],
    "max-len": "off",
    "no-console": 1,
    "no-underscore-dangle": ["error", { "allow": ["_id", "__typename", "__schema"] }],
    "no-param-reassign": 0,
    "no-shadow": "off",
    "object-curly-newline": "off",
    "indent": ["error", 2, { "SwitchCase": 1 }],
    "import/no-unresolved": [2, { "commonjs": true }],
    "import/extensions": ["error", "never", { "json": "always" }],
    "import/no-dynamic-require": "off",
    "import/prefer-default-export": "off",
    "jsx-a11y/anchor-is-valid": "off",
    "jsx-a11y/media-has-caption": "off",
    "jsx-a11y/label-has-associated-control": [
      "error",
      {
        "required": {
          "some": ["nesting", "id"]
        }
      }
    ],
    "jsx-a11y/label-has-for": [
      "error",
      {
        "required": {
          "some": ["nesting", "id"]
        }
      }
    ],
    "jsx-quotes": ["error", "prefer-double"],
    "quotes": ["error", "single"],
    "react/jsx-uses-vars": "error",
    "react/no-array-index-key": "off",
    "react/forbid-prop-types": "off",
    "react/jsx-one-expression-per-line": 0,
    "react/no-find-dom-node": 1,
    "react/jsx-uses-react": "off",
    "react/no-string-refs": 1,
    "react/no-danger": "off",
    "react/prop-types": 2,
    "react/react-in-jsx-scope": "off",
    "react/jsx-filename-extension": [2, { "extensions": [".js", ".jsx", ".ts", ".tsx"] }],
    "react/jsx-props-no-spreading": "off",
    "semi": ["error", "always"]
  },
  "settings": {
    "import/resolver": {
      "alias": {
        "map": [
          ["@/lib", "./lib/"],
          ["@/components", "./components/"],
          ["@/context", "./context/"],
          ["@/constants", "./constants.js"],
          ["@/theme", "./theme/"],
          ["@/theme.config", "./theme.config"],
          ["@/utils", "./utils/"],
          ["@/hooks", "./hooks/"],
          ["@/error", "./pages/_error.jsx"],
          ["@/queries", "./lib/queries/"],
          ["@/data", "./data/"],
          ["@/views", "./views/"]
        ],
        "extensions": [".js", ".jsx", ".json"]
      },
      "node": {
        "moduleDirectory": ["node_modules", "src/"]
      }
    }
  }
}' >> .eslintrc${config_extension}
fi


if [ "$skip_prettier_setup" == "true" ]; then
  break
else
  echo -e "5/5 ${YELLOW}Building your .prettierrc${config_extension} file... ${NC}"
  > .prettierrc${config_extension} # truncates existing file (or creates empty)

  echo ${config_opening}'
  "printWidth": '${max_len_val}',
  "singleQuote": true,
  "trailingComma": "'${trailing_comma_pref}'",
  "arrowParens": "always",
  "bracketSpacing": true,
  "insertPragma": false,
  "proseWrap": "preserve",
  "requirePragma": false,
  "semi": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "useTabs": false,
  "overrides": [
    {
      "files": "*.scss",
      "options": {
        "singleQuote": false
      }
    }
  ]
}' >> .prettierrc${config_extension}
fi

echo
echo -e "${GREEN}Finished setting up!${NC}"
echo

