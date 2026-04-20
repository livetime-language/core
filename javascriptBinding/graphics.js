function getVector2(value, x = 0, y = 0) {
	return value?.x != undefined || value?.y != undefined ? value : new Vector2(value ?? x, value == undefined ? y : 0)
}

function drawImage(image, position, options) {
	options ||= {}
	position ||= new Vector2(0, 0)
	let scale = options.scale ?? 1
	let size = getVector2(options.size)
	let visibleFor = options.visibleFor
	let clickableBy = options.clickableBy
	let framesPerSecond = options.framesPerSecond ?? 0
	let frameOffset = options.frameOffset ?? 0
	let frameCount = options.frameCount ?? 0
	let layer = options.layer ?? int.minValue
	let alpha = options.alpha ?? 1
	let color = options.color ?? Color.White
	let align = options.align ?? 1
	let valign = options.valign ?? 1
	let angle = options.angle ?? 0
	let flipX = options.flipX ?? false
	let flipY = options.flipY ?? false
	let clickableMargin = getVector2(options.clickableMargin, 16, 16)
	let showClickableArea = options.showClickableArea ?? false
	let hotkey = options.hotkey ?? 0
	let onClick = options.onClick || (() => {})
	let location = options.location
	let isAnimated = options.framesPerSecond != undefined || options.frameOffset != undefined || options.frameCount != undefined
	let isRotated = angle != 0 || flipX || flipY
	let isClickable = clickableBy != undefined || options.clickableMargin != undefined || options.showClickableArea != undefined || options.hotkey != undefined || options.onClick != undefined
	let frame

	if(isAnimated) {
		let effectiveFrameCount = frameCount || image.frames.length
		frame = ((Math.floor(core.frame * Math.max(framesPerSecond, 0) / core.ticksPerSecond + frameOffset) % effectiveFrameCount) + effectiveFrameCount) % effectiveFrameCount
	} else {
		frame = options.frame ?? 0
	}

	if(isRotated && (align != 1 || valign != 1)) {
		let currentFrame = image.frames[frame % image.frames.length]
		let sizeX = (size.x || currentFrame.w) * scale
		let sizeY = size.y ? size.y * scale : sizeX * currentFrame.h / currentFrame.w
		let alignmentFactor = graphics.alignmentFactor || [0, .5, 1]
		position = position._plus(new Vector2((.5 - alignmentFactor[align]) * sizeX, (.5 - alignmentFactor[valign]) * sizeY))
	}

	if(isClickable) {
		if(isRotated) {
			graphics.drawImage6(image, position, scale, size, visibleFor, clickableBy, frame, layer, alpha, color, angle, flipX, flipY, clickableMargin, showClickableArea, hotkey, onClick, location)
		} else {
			graphics.drawImage5(image, position, scale, size, visibleFor, clickableBy, frame, layer, alpha, color, align, valign, clickableMargin, showClickableArea, hotkey, onClick, location)
		}
		return
	}

	if(isAnimated) {
		if(isRotated) {
			graphics.drawImage4(image, position, scale, size, visibleFor, framesPerSecond, frameOffset, frameCount, layer, alpha, color, angle, flipX, flipY, location)
		} else {
			graphics.drawImage3(image, position, scale, size, visibleFor, framesPerSecond, frameOffset, frameCount, layer, alpha, color, location)
		}
		return
	}

	if(isRotated) {
		graphics.drawImage2(image, position, scale, size, visibleFor, frame, layer, alpha, color, angle, flipX, flipY, location)
	} else {
		graphics.drawImage(image, position, scale, size, visibleFor, frame, layer, alpha, color, align, valign, location)
	}
}

function drawSlicedImage(image, position, options) {
	options ||= {}
	graphics.drawSlicedImage(image, position || new Vector2(0, 0), getVector2(options.size), options.visibleFor, options.frame ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.color ?? Color.White, options.leftSlice ?? 0, options.rightSlice ?? 0, options.align ?? 1, options.valign ?? 1, options.location)
}
function drawPartialImage(image, position, options) {
	options ||= {}
	graphics.drawPartialImage(image, position || new Vector2(0, 0), options.scale ?? 1, getVector2(options.size), getVector2(options.sourcePosition), getVector2(options.sourceSize), options.visibleFor, options.frame ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.color ?? Color.White, options.align ?? 1, options.valign ?? 1, options.location)
}
function drawText(text, position, options) {
	options ||= {}
	return graphics.drawText(text, position || new Vector2(0, 0), getVector2(options.size), options.color ?? null, options.align ?? 1, options.valign ?? 1, options.style ?? 0, options.font ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.angle ?? 0, options.visibleFor, options.clickableBy, getVector2(options.clickableMargin, 16, 16), options.showClickableArea ?? false, options.hotkey ?? 0, options.overflow ?? 2, options.maxWidth ?? 0, options.lineHeight ?? 0, options.onClick ?? null, options.location)
}
function drawTextWithHighlight(text, position, options) {
	options ||= {}
	return graphics.drawTextWithHighlight(text, position || new Vector2(0, 0), options.highlights || [], getVector2(options.size), options.color ?? null, options.align ?? 1, options.valign ?? 1, options.style ?? 0, options.font ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.angle ?? 0, options.visibleFor, options.clickableBy, getVector2(options.clickableMargin, 16, 16), options.showClickableArea ?? false, options.hotkey ?? 0, options.overflow ?? 2, options.maxWidth ?? Number.MAX_VALUE, options.lineHeight ?? 0, options.onClick ?? null, options.location)
}
function drawCircularText(text, position, options) {
	options ||= {}
	graphics.drawCircularText(text, position || new Vector2(0, 0), options.size ?? 0, options.color ?? null, options.font ?? null, options.layer ?? int.minValue, options.radius ?? 100, options.angle ?? 0, options.spacing ?? .2, options.visibleFor, options.location)
}
function drawButton(text, position, options) {
	options ||= {}
	graphics.drawButton(options.image ?? null, text ?? "", position || new Vector2(0, 0), getVector2(options.size), options.frame ?? -1, options.textColor ?? null, options.textSize ?? 24, getVector2(options.textOffset), getVector2(options.clickableMargin, 16, 16), options.showClickableArea ?? false, options.scaleOnHover ?? 1, options.frameOnHover ?? 1, options.textColorOnHover ?? null, options.accentImage ?? null, options.accentColor ?? null, options.visibleFor, options.clickableBy, options.hotkey ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.enabled ?? true, options.alphaWhenDisabled ?? .5, options.onClick ?? null, options.location)
}
function drawRectangle(position, size, options) {
	options ||= {}
	graphics.drawRectangle(position || new Vector2(0, 0), getVector2(size, 256, 256), options.color ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1, options.align ?? 1, options.valign ?? 1, options.location)
}
function drawRoundedRectangle(position, size, options) {
	options ||= {}
	graphics.drawRoundedRectangle(position || new Vector2(0, 0), getVector2(size, 256, 256), options.radius ?? 32, options.color ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1, options.align ?? 1, options.valign ?? 1)
}
function drawCircle(position, size, options) {
	options ||= {}
	graphics.drawCircle(position || new Vector2(0, 0), getVector2(size, 256, 256), options.color ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.startAngle ?? 0, options.angle ?? math.twoPi, options.direction ?? 1, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1, options.location)
}
function drawLine(from, to, options) {
	options ||= {}
	graphics.drawLine(from, to, options.color ?? null, options.width ?? 0, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1)
}
function drawLines(points, options) {
	options ||= {}
	graphics.drawLines(points, getVector2(options.position), options.color ?? null, options.width ?? 0, options.smooth ?? false, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1)
}
function drawArrow(from, to, options) {
	options ||= {}
	graphics.drawArrow(from, to, options.width ?? 18, options.arrowHeadWidth ?? 0, options.arrowHeadLength ?? 0, options.color ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1)
}
function drawPolygon(points, options) {
	options ||= {}
	graphics.drawPolygon(points, getVector2(options.position), options.color ?? null, options.outlineColor ?? null, options.outlineWidth ?? 0, options.smooth ?? false, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1)
}
function drawVideo(player, position, options) {
	options ||= {}
	graphics.drawVideo(player, position || new Vector2(0, 0), getVector2(options.size, 440, 0), options.shape ?? 0, options.visibleFor, options.location)
}
function drawPointer(player, options) {
	options ||= {}
	graphics.drawPointer(player, options.mode ?? 2, options.color ?? null)
}
function drawTexture(texture, position, options) {
	options ||= {}
	let size = getVector2(options.size)
	if(options.sourcePosition != undefined || options.sourceSize != undefined) graphics.drawTexture2(texture, position || new Vector2(0, 0), size, getVector2(options.sourcePosition), getVector2(options.sourceSize), options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1, options.color ?? Color.White)
	else graphics.drawTexture(texture, position || new Vector2(0, 0), size, options.visibleFor, options.layer ?? int.minValue, options.alpha ?? 1, options.color ?? Color.White)
}
function drawStandardButton(text, position, options) {
	options ||= {}
	graphics.drawButton(media.Button, text ?? "", position || new Vector2(0, 0), new Vector2(0, 0), -1, null, 24, new Vector2(0, 0), new Vector2(16, 16), false, 1, 1, Color.Black, media.ButtonAccent, options.accentColor ?? null, options.visibleFor, options.clickableBy, options.hotkey ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.enabled ?? true, .5, options.onClick ?? null, options.location)
}
function drawLargeButton(text, position, options) {
	options ||= {}
	graphics.drawButton(media.LargeButton, text ?? "", position || new Vector2(0, 0), new Vector2(0, 0), -1, null, options.textSize ?? 24, new Vector2(0, 0), new Vector2(16, 16), false, 1, 1, Color.Black, media.LargeButtonAccent, options.accentColor ?? null, options.visibleFor, options.clickableBy, options.hotkey ?? 0, options.layer ?? int.minValue, options.alpha ?? 1, options.enabled ?? true, .5, options.onClick ?? null, options.location)
}

function print(text, options) {
	options ||= {}
	System.print(String(text ?? ""), options.type ?? "info", options.color ?? null, options.drawDebugInfo ?? null, options.location)
}

function animate(duration, tick, then, delay = 0) {
	fx.animate(delay, duration, { invoke: tick }, then ? { invoke: then } : null)
}

function whenAnimationsFinished(onComplete) {
	fx.whenAnimationsFinished({ invoke: onComplete })
}

function createMenu(options) {
	options ||= {}
	return new Menu(
		options.position || new Vector2(920, -500),
		options.size || new Vector2(0, 0),
		options.angle ?? 0,
		options.alpha ?? 1,
		options.visibleFor ?? null,
		options.layer ?? 1,
		options.locked ?? true,
		options.location,
		options.popupPosition || new Vector2(0, 0),
		options.items || [],
		options.includeDefaultItems ?? true,
		options.overlayColor || new Color("#000000b0")
	)
}

function createParticleSystem(options) {
	options ||= {}
	return new ParticleSystem(
		options.position || new Vector2(0, 0),
		options.size || new Vector2(0, 0),
		options.angle ?? 0,
		options.alpha ?? 1,
		options.visibleFor ?? null,
		options.layer ?? int.maxValue,
		options.locked ?? false,
		options.location,
		options.image ?? media.Spark,
		options.minSpeed ?? 10,
		options.maxSpeed ?? 20,
		options.particlesPerBurst ?? 30,
		options.burstInterval ?? 500,
		options.nextBurst ?? -1,
		options.bursts ?? 1,
		options.gravity ?? .5,
		options.maxRotationSpeed ?? .05,
		options.mode ?? 0,
		options.angleSpread ?? .5
	)
}

var media