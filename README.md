hivemind
--------

Install deps

```
$ make deps
```

Run locally:

```
$ make run
```

Run tests:

```
$ make test
```

## CSS

The CSS is powered by [Tailwind] and generated with [PostCSS], to get going locally run `yarn` to install the dependencies and then `yarn css` to make the CSS.

`yarn css` also watches for any changes and recompiles. For production builds in uses [PurgeCSS] to remove any unused classes and `cssnano` to minify it.



[Tailwind]: https://tailwindcss.com/
[PostCSS]: https://postcss.org/
[PurgeCSS]: https://purgecss.com
