const babel = heap.require('gulp-babel');

module.exports = (profile = "default") => {
  const cfg = config["es6:" + profile];
  return gulp.task(cfg.taskName, babel(cfg.src, cfg.dst, cfg._useBabelRc ? null : cfg.opts).with(heap.sourcemaps()).if(cfg.sourceMap));
};
