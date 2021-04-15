const is_prod_like = process.env.NODE_ENV === "production";

module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    ...(is_prod_like ? { cssnano: {} } : {}),
  },
};
