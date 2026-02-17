const requestLogger = (req, res, next) => {
  const start = Date.now();

  res.on('finish', () => {
    const duration = Date.now() - start;
    const timestamp = new Date().toISOString();
    const status = res.statusCode;
    const statusColor = status >= 400 ? '\x1b[31m' : status >= 300 ? '\x1b[33m' : '\x1b[32m';
    const reset = '\x1b[0m';

    const log = `[${timestamp}] ${req.method} ${req.path} ${statusColor}${status}${reset} ${duration}ms`;
    
    console.log(log);
  });

  next();
};

module.exports = requestLogger;
