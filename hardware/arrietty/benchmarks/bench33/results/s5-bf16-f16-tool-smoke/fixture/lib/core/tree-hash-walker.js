TreeHashWalker.prototype.done = function () {
    return Object.assign({}, this._result, {error: this.error});
};

module.exports = TreeHashWalker;
