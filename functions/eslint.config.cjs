module.exports = [
    {
        languageOptions: {
            ecmaVersion: 2021,
            sourceType: "module",
            globals: {
                // Node.js globals
                process: "readonly",
                __dirname: "readonly",
                __filename: "readonly",
                exports: "readonly",
                module: "readonly",
                require: "readonly",
                // ES2021 globals
                console: "readonly",
                Promise: "readonly",
            },
        },
        rules: {
            // ESLint recommended rules
            "no-console": "warn",
            "no-debugger": "error",
            "no-dupe-args": "error",
            "no-dupe-keys": "error",
            "no-duplicate-case": "error",
            "no-extra-semi": "error",
            "no-func-assign": "error",
            "no-obj-calls": "error",
            "no-unreachable": "error",
            "use-isnan": "error",
            "valid-typeof": "error",

            // Google style guide rules
            "quotes": ["error", "double"],
            "indent": ["error", 4],
            "object-curly-spacing": ["error", "always"],
            "max-len": ["error", { "code": 120 }],
            "comma-dangle": ["error", "always-multiline"],
            "semi": ["error", "always"],
            "no-unused-vars": ["warn", { "argsIgnorePattern": "^_" }],
            "arrow-parens": ["error", "always"],
            "eol-last": "error",
            "no-trailing-spaces": "error",
            "no-multiple-empty-lines": ["error", { "max": 1, "maxEOF": 1 }],
            "space-infix-ops": "error",
            "space-before-blocks": "error",
            "keyword-spacing": ["error", { "before": true, "after": true }],
            "brace-style": ["error", "1tbs", { "allowSingleLine": true }],
            "space-before-function-paren": ["error", {
                "anonymous": "never",
                "named": "never",
                "asyncArrow": "always"
            }],

            // Disabled rules
            "require-jsdoc": "off",
            "camelcase": "off",
        },
        files: ["**/*.js"],
        ignores: ["node_modules/**"],
    },
];
