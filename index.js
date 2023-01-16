'use strict'

const path = require('path')

module.exports = (robot) => {
  const scriptsPath = path.resolve(__dirname, 'src')
  robot.loadFile(scriptsPath, 'tumble.coffee')
  robot.loadFile(scriptsPath, 'quotes.coffee')
  robot.loadFile(scriptsPath, 'delete_tumble.coffee')
}
