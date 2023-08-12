

```Makefile
public/output.min.js: src/input.js
    cat src/index.js | $(ROLLUP_DIR)/run.sh > public/index.min.js
```
