String.prototype.startswith = function(s) {
    return (this.length >= s.length) && (this.substr(0, s.length) == s);
};