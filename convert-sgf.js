// written by comonoid

const fs = require('fs')

const file = process.argv[2]
const keepColors = process.argv.includes('--keep-colors')

const sgf = fs.readFileSync(file).toString()

const alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
const toLetter = d => alphabet[d - 1]
const fromLetter = l => alphabet.indexOf(l) + 1

const fromLN = (f, r) => [fromLetter(f), Number(r)]
const toLN = ([f, r]) => toLetter(f) + r
const toLL = ([f, r]) => toLetter(f) + toLetter(r)

const convertToRectangular = ([f, r]) => [f * 2 + r - 1, r * 2]

const showLizzieSgfMove = ({ color, coords }) =>
  `${color}[${toLL(convertToRectangular(coords))}]`

const swap = ([f, r]) => [r, f]
const invertColor = color => color.toUpperCase() === 'W' ? 'B' : 'W'
const invertMove = ({ color, coords }) =>
  ({ color: invertColor(color), coords: swap(coords) })

let invert = false

const output = sgf
  .replace(/(W|B)\[(\w)(\d+)\];(?:W|B)\[swap-pieces\]/i, (_, color, f, r) => {
    if (!keepColors) invert = true
    const move = { color, coords: fromLN(f, r) }
    return showLizzieSgfMove(invert ? move : invertMove(move))
  })
  .replace(/(W|B)\[(\w)(\d+)\]/ig, (_, color, f, r) => {
    const move = { color, coords: fromLN(f, r) }
    return showLizzieSgfMove(invert ? invertMove(move) : move)
  })
  .replace(/;(?:W|B)\[swap-sides\]/i, '')
  .replace(/;(?:W|B)\[resign\]/i, '')
  .replace(/;(?:W|B)\[forfeit\]/i, '')

console.log(output)
