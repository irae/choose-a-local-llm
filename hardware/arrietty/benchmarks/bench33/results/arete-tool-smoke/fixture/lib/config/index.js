function loadConfig(fileConfig, config) {
    return Object.assign({}, fileConfig, config);
}

module.exports = loadConfig;
