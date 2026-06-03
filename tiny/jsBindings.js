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
function drawRect(x = 0, y = 0, width = 8, height = 8, fillColor = 7, strokeColor = 0, strokeWidth = 0) {
	graphics.drawRect(new Vector2(x, y), new Vector2(width, height), fillColor, strokeColor, strokeWidth);
}
function drawCircle(x = 0, y = 0, radius = 8, fillColor = 7, strokeColor = 0, strokeWidth = 0) {
	graphics.drawCircle(new Vector2(x, y), new Vector2(radius, radius), fillColor, strokeColor, strokeWidth);
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

// core/tiny/input.l
const AButton = 0;
const BButton = 1;
const XButton = 2;
const YButton = 3;
const LeftBumper = 4;
const RightBumper = 5;
const LeftTrigger = 6;
const RightTrigger = 7;
const Select = 8;
const Start = 9;
const LeftStickButton = 10;
const RightStickButton = 11;
const Up = 12;
const Down = 13;
const Left = 14;
const Right = 15;
const LeftMouseButton = 16;
const MiddleMouseButton = 17;
const RightMouseButton = 18;

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