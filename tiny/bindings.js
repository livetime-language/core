// Colors
var Black = 0
var DarkBlue = 1
var DarkPurple = 2
var DarkGreen = 3
var Brown = 4
var DarkGray = 5
var LightGray = 6
var White = 7
var Red = 8
var Orange = 9
var Yellow = 10
var Green = 11
var Blue = 12
var Indigo = 13
var Pink = 14
var Peach = 15

// core/tiny/graphics.l
function getPixel(x = 0, y = 0) {
	return graphics.getPixel(new Vector2(x, y));
}
function setPixel(x = 0, y = 0, color = 7) {
	graphics.setPixel(new Vector2(x, y), color);
}
function drawSprite(sprite, x = 0, y = 0) {
	graphics.drawSprite(sprite, new Vector2(x, y));
}
function drawText(text = "", x = 0, y = 0, color = 7) {
	graphics.drawText(text, new Vector2(x, y), color);
}
function drawRect(x = 0, y = 0, width = 8, height = 8, color = 7, strokeColor = 0, strokeWidth = 0) {
	graphics.drawRect(new Vector2(x, y), new Vector2(width, height), color, strokeColor, strokeWidth);
}
function drawCircle(x = 0, y = 0, radius = 8, color = 7, strokeColor = 0, strokeWidth = 0) {
	graphics.drawCircle(new Vector2(x, y), new Vector2(radius, radius), color, strokeColor, strokeWidth);
}
function clip(x = 0, y = 0, width = 0, height = 0) {
	graphics.clip(new Vector2(x, y), new Vector2(width, height));
}
function stopClipping() {
	graphics.stopClipping();
}
function replaceColor(oldColor = 0, newColor = 0) {
	graphics.replaceColor(oldColor, newColor);
}
function stopReplacingColors() {
	graphics.stopReplacingColors();
}

// Buttons
var ButtonA = 0;
var ButtonB = 1;
var ButtonX = 2;
var ButtonY = 3;
var LeftBumper = 4;
var RightBumper = 5;
var LeftTrigger = 6;
var RightTrigger = 7;
var Select = 8;
var Start = 9;
var LeftStickButton = 10;
var RightStickButton = 11;
var Up = 12;
var Down = 13;
var Left = 14;
var Right = 15;
var LeftMouseButton = 16;
var MiddleMouseButton = 17;
var RightMouseButton = 18;

// core/tiny/input.l
function justPressed(button, player = 0) {
	return input.justPressed(button, player);
}
function justReleased(button, player = 0) {
	return input.justReleased(button, player);
}
function isPressed(button, player = 0) {
	return input.isPressed(button, player);
}
function getPointer(player = 0) {
	return input.getPointer(player);
}
function getScrollDelta(player = 0) {
	return input.getScrollDelta(player);
}