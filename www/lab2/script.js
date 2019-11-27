const PUZZLE_HOVER_TINT = '#009900';
const PUZZLE_MAX_WIDTH = 1000;
const PUZZLE_MAX_HEIGHT = 1000;
const MARGIN = 10;

var _puzzleRows = 4;
var _puzzleColumns = 4;

var _canvas;
var _stage;
var _imgSrc;

var _img;
var _pieces;
var _imgWidth;
var _imgHeight;
var _puzzleWidth;
var _puzzleHeight;
var _srcPieceWidth;
var _srcPieceHeight;
var _dstPieceWidth;
var _dstPieceHeight;
var _currentPiece;
var _currentDropPiece;

var _mouse;

function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, '\\$&');
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}

function init(){
    window.onresize = null;
    document.onclick = null;
    document.onmousemove = null;
    document.onmousedown = null;
    _img = new Image();
    _img.addEventListener('load',onImage,false);
    _imgSrc = getParameterByName("imgSrc");
    _img.src = _imgSrc;
    if (_img.height === 0) {
        _img.src = "xp1080.jpg";
    }
}

function onImage(e){
    setCanvas();
    _srcPieceWidth = Math.floor(_img.width / _puzzleColumns);
    _srcPieceHeight = Math.floor(_img.height / _puzzleRows);
    _imgWidth = _img.width;
    _imgHeight = _img.height;
    setDstDims();
    initPuzzle();
}

function setDstDims() {
    if (window.innerWidth <= PUZZLE_MAX_WIDTH + 2 * MARGIN) {
        _canvas.width = window.innerWidth - 2 * MARGIN;
    } else {
        _canvas.width = PUZZLE_MAX_WIDTH;
    }
    if (window.innerHeight <= PUZZLE_MAX_HEIGHT + 2 * MARGIN) {
        _canvas.height = window.innerHeight - 2 * MARGIN;
    } else {
        _canvas.height = PUZZLE_MAX_HEIGHT;
    }
    _puzzleWidth = _canvas.width;
    _puzzleHeight = _canvas.height;
    _dstPieceWidth = Math.floor(_puzzleWidth / _puzzleColumns);
    _dstPieceHeight = Math.floor(_puzzleHeight / _puzzleRows);
}

function setCanvas(){
    _canvas = document.getElementById('mainCanvas');
    _stage = _canvas.getContext('2d');
    _canvas.style.border = "1px solid black";
}

function onResize() {
    setDstDims();
    _stage.fillStyle = 'red';
    updatePuzzle(NaN);
}

function onResizePreShuffle() {
    setDstDims();
    _stage.drawImage(_img, 0, 0, _imgWidth, _imgHeight, 0, 0, _puzzleWidth, _puzzleHeight);
    createTitle("Click to Start Puzzle");
}

function initPuzzle(){
    _pieces = [];
    _mouse = {x:0,y:0};
    _currentPiece = null;
    _currentDropPiece = null;
    _stage.drawImage(_img, 0, 0, _imgWidth, _imgHeight, 0, 0, _puzzleWidth, _puzzleHeight);
    createTitle("Click to Start Puzzle");
    buildPieces();
}

function createTitle(msg){
    _stage.fillStyle = "#000000";
    _stage.globalAlpha = .4;
    _stage.fillRect(100,_puzzleHeight - 40,_puzzleWidth - 200,40);
    _stage.fillStyle = "#FFFFFF";
    _stage.globalAlpha = 1;
    _stage.textAlign = "center";
    _stage.textBaseline = "middle";
    _stage.font = "20px Arial";
    _stage.fillText(msg,_puzzleWidth / 2,_puzzleHeight - 20);
}

function buildPieces(){
    var i;
    var piece;
    var xPos = 0;
    var yPos = 0;
    for(i = 0;i < _puzzleRows * _puzzleColumns;i++){
        piece = {};
        piece.red = i === 0;
        piece.sx = xPos;
        piece.sy = yPos;
        _pieces.push(piece);
        xPos++;
        if(xPos >= _puzzleColumns){
            xPos = 0;
            yPos++;
        }
    }
    window.onresize = onResizePreShuffle;
    document.onmousedown = shufflePuzzle;
}

function shufflePuzzle(){
    _stage.fillStyle = 'red';
    _pieces = shuffleArray(_pieces);
    _stage.clearRect(0,0,_puzzleWidth,_puzzleHeight);
    var i;
    var piece;
    var xPos = 0;
    var yPos = 0;
    for(i = 0;i < _pieces.length;i++){
        piece = _pieces[i];
        piece.xPos = xPos;
        piece.yPos = yPos;
        if (piece.red) {
            _stage.fillRect(piece.xPos * _dstPieceWidth, piece.yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        } else {
            _stage.drawImage(_img, piece.sx * _srcPieceWidth, piece.sy * _srcPieceHeight, _srcPieceWidth, _srcPieceHeight, xPos * _dstPieceWidth, yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        }
        _stage.strokeRect(xPos * _dstPieceWidth, yPos * _dstPieceHeight, _dstPieceWidth,_dstPieceHeight);
        xPos++;
        if(xPos >= _puzzleColumns){
            xPos = 0;
            yPos++;
        }
    }
    //document.onmousedown = onPuzzleClick;
    window.onresize = onResize;
    document.onclick = movePiece;
    document.onmousemove = updatePuzzle;
    document.onmousedown = null;
}

function shuffleArray(o){
    for(var j, x, i = o.length; i; j = parseInt(Math.random() * i), x = o[--i], o[i] = o[j], o[j] = x);
    return o;
}

function movePiece(e) {
    if(e.layerX || e.layerX == 0){
        _mouse.x = e.layerX - _canvas.offsetLeft;
        _mouse.y = e.layerY - _canvas.offsetTop;
    }
    else if(e.offsetX || e.offsetX == 0){
        _mouse.x = e.offsetX - _canvas.offsetLeft;
        _mouse.y = e.offsetY - _canvas.offsetTop;
    }
    _currentPiece = checkPieceClicked();
    let neighbour;
    if(_currentPiece != null && (neighbour = findNeighbour()) != null){
        let tempX = _currentPiece.xPos;
        let tempY = _currentPiece.yPos;
        _currentPiece.xPos = neighbour.xPos;
        _currentPiece.yPos = neighbour.yPos;
        neighbour.xPos = tempX;
        neighbour.yPos = tempY;
        resetPuzzleAndCheckWin();
    }
}

function findNeighbour() {
    let i;
    for (i=0; i<_pieces.length; i++) {
        let piece = _pieces[i];
        if (piece.red) {
            if ((piece.yPos === _currentPiece.yPos && (piece.xPos === _currentPiece.xPos-1 || piece.xPos === _currentPiece.xPos+1)) || (piece.xPos === _currentPiece.xPos && (piece.yPos === _currentPiece.yPos-1 || piece.yPos === _currentPiece.yPos+1))) {
                return piece;
            } else {
                return null;
            }
        }
    }
    return null;
}

function checkPieceClicked(){
    var i;
    var piece;
    for(i = 0;i < _pieces.length;i++){
        piece = _pieces[i];
        if(_mouse.x < piece.xPos * _dstPieceWidth || _mouse.x > (piece.xPos + 1) * _dstPieceWidth || _mouse.y < piece.yPos * _dstPieceHeight || _mouse.y > (piece.yPos + 1) * _dstPieceHeight){
            //PIECE NOT HIT
        }
        else{
            return piece;
        }
    }
    return null;
}

function updatePuzzle(e){
    _currentDropPiece = null;
    if(e.layerX || e.layerX == 0){
        _mouse.x = e.layerX - _canvas.offsetLeft;
        _mouse.y = e.layerY - _canvas.offsetTop;
    }
    else if(e.offsetX || e.offsetX == 0){
        _mouse.x = e.offsetX - _canvas.offsetLeft;
        _mouse.y = e.offsetY - _canvas.offsetTop;
    }
    _stage.clearRect(0,0,_puzzleWidth,_puzzleHeight);
    var i;
    for(i = 0;i < _pieces.length;i++){
        _currentPiece = _pieces[i];
        if (_currentPiece.red) {
            _stage.fillRect(_currentPiece.xPos * _dstPieceWidth, _currentPiece.yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        } else {
            _stage.drawImage(_img, _currentPiece.sx * _srcPieceWidth, _currentPiece.sy * _srcPieceHeight, _srcPieceWidth, _srcPieceHeight, _currentPiece.xPos * _dstPieceWidth, _currentPiece.yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        }
        _stage.strokeRect(_currentPiece.xPos * _dstPieceWidth, _currentPiece.yPos * _dstPieceHeight, _dstPieceWidth,_dstPieceHeight);
        if(_currentDropPiece == null){
            if(_mouse.x < _currentPiece.xPos * _dstPieceWidth || _mouse.x > (_currentPiece.xPos + 1) * _dstPieceWidth || _mouse.y < _currentPiece.yPos * _dstPieceHeight || _mouse.y > (_currentPiece.yPos + 1) * _dstPieceHeight){
                //NOT OVER
            }
            else if (findNeighbour() != null){
                _currentDropPiece = _currentPiece;
                _stage.save();
                _stage.globalAlpha = .4;
                _stage.fillStyle = PUZZLE_HOVER_TINT;
                _stage.fillRect(_currentDropPiece.xPos * _dstPieceWidth,_currentDropPiece.yPos * _dstPieceHeight,_dstPieceWidth, _dstPieceHeight);
                _stage.restore();
            }
        }
    }
    /*_stage.save();
    _stage.globalAlpha = .6;
    if (_currentPiece.red) {
        _stage.fillRect(_mouse.x - (_pieceWidth / 2), _mouse.y - (_pieceHeight / 2), _pieceWidth, _pieceHeight);
    } else {
        _stage.drawImage(_img, _currentPiece.sx, _currentPiece.sy, _pieceWidth, _pieceHeight, _mouse.x - (_pieceWidth / 2), _mouse.y - (_pieceHeight / 2), _pieceWidth, _pieceHeight);
    }
    _stage.restore();
    _stage.strokeRect( _mouse.x - (_pieceWidth / 2), _mouse.y - (_pieceHeight / 2), _pieceWidth,_pieceHeight);*/
}

function resetPuzzleAndCheckWin(){
    _stage.clearRect(0,0,_puzzleWidth,_puzzleHeight);
    var gameWin = true;
    var i;
    var piece;
    for(i = 0;i < _pieces.length;i++){
        piece = _pieces[i];
        if (piece.red) {
            _stage.fillRect(piece.xPos * _dstPieceWidth, piece.yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        } else {
            _stage.drawImage(_img, piece.sx * _srcPieceWidth, piece.sy * _srcPieceHeight, _srcPieceWidth, _srcPieceHeight, piece.xPos * _dstPieceWidth, piece.yPos * _dstPieceHeight, _dstPieceWidth, _dstPieceHeight);
        }
        _stage.strokeRect(piece.xPos * _dstPieceWidth, piece.yPos * _dstPieceHeight, _dstPieceWidth,_dstPieceHeight);
        if(piece.xPos != piece.sx || piece.yPos != piece.sy){
            gameWin = false;
        }
    }
    if(gameWin){
        setTimeout(gameOver,500);
    }
}

function gameOver(){
    document.onmousedown = null;
    document.onmousemove = null;
    document.onmouseup = null;
    initPuzzle();
}