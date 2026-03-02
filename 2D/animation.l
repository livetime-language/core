global unit fx
	internal Animation[] animations
	importance:4 global bool runningAnimations => animations.length > 0

	importance:4
	global animate: float delay = 0	// Start animation after this time in milliseconds
		            float duration = 300	// The duration of the animation in milliseconds
		            stored void(float progress, float time) tick	// Execute this code on every tick of the animation, passing in the progress (0 to 1) and elapsed time in milliseconds
				    stored void() then = null	// Execute this code once after the animation finishes
		add InterpolateAnimation startTime:Time.now+delay, duration
			graphics.currentLayer += 65535
			tick(progress, time)
			graphics.currentLayer -= 65535
			if progress >= 1 and then != null then then()

	private void()[] whenAllAnimationsFinishedCallbacks

	importance:4
	global whenAllAnimationsFinished: stored void() do
		if animations.length == 0
			do()
		else
			whenAllAnimationsFinishedCallbacks.add do

	global delay: float time = 0 // The delay in milliseconds
		          stored void() do
		add DelayAnimation startTime:Time.now+time, do
				
	add: Animation animation
		animations.add animation
		
	removeForObject: Object object
		animations.removeWhere.object == object
		
	endOfPrevAnimation: Object object
		let lastAnimation = animations.last
		if lastAnimation?.object == object
			return math.max(Time.now, lastAnimation.startTime + lastAnimation.duration)
		return Time.now
		
	internal tick
		if animations.length == 0 then return
		let now = Time.now
		for animations <-
			if now >= .startTime
				float time = now - .startTime
				float progress = .duration ? time/.duration : 1
				if progress >= 1 then progress = 1; animations.removeAt i
				.tick progress, time

		if animations.length == 0
			for whenAllAnimationsFinishedCallbacks as callback
				callback()
			whenAllAnimationsFinishedCallbacks.clear
				
	// Animate a variable to a target value over a given period of time
	importance:0 inline animateVariable: float variable = 0   // The variable to animate
		                   float to = 1         // The target value to animate to
		                   float delay = 0      // The delay before the animation starts in milliseconds
		                   float duration = 300 // The duration of the animation in milliseconds
		animateValue variable, to, delay, duration, variable = .
		
	// Animate a variable to a target value over a given period of time
	importance:0 inline animateVariable: float variable = 0   // The variable to animate
		                   float to = 1         // The target value to animate to
		                   float delay = 0       // The delay before the animation starts in milliseconds
		                   float duration = 300  // The duration of the animation in milliseconds
		                   EaseFunction ease    // The easing function to apply
		animateValue variable, to, delay, duration, ease, variable = .
		
	// Animate a variable to a target value over a given period of time
	importance:0 inline animateVariable: Vector2 variable    // The variable to animate
		                   Vector2 to          // The target vector to animate to
		                   float delay = 0      // The delay before the animation starts in milliseconds
		                   float duration = 300 // The duration of the animation in milliseconds
		animateValue variable, to, delay, duration, variable = .
		
	// Animate a variable to a target value over a given period of time
	importance:0 inline animateVariable: Vector2 variable    // The variable to animate
		                   Vector2 to          // The target vector to animate to
		                   float delay = 0      // The delay before the animation starts in milliseconds
		                   float duration = 300 // The duration of the animation in milliseconds
		                   EaseFunction ease   // The easing function to apply
		animateValue variable, to, delay, duration, ease, variable = .
		
	// Animate a variable to a target value over a given period of time
	importance:0 inline animateVariable: Color variable      // The variable to animate
		                   Color to            // The target color to animate to
		                   float delay = 0      // The delay before the animation starts in milliseconds
		                   float duration = 300 // The duration of the animation in milliseconds
		animateValue variable, to, delay, duration, variable = .
		
	importance:0 animateValue: float from = 0
		         float to = 1
		         stored void(float progress) do
		         float delay = 0       // The delay in milliseconds
		         float duration = 300  // The duration in milliseconds
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from + (to - from) * .)
				
	importance:0 animateValue: float from = 0
		         float to = 1
		         stored void(float progress) do
		         float delay = 0       // The delay in milliseconds
		         float duration = 300  // The duration in milliseconds
		         EaseFunction ease
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(ease.function(from + (to - from) * .))
				
	importance:0 animateValue: Vector2 from
		         Vector2 to
		         stored void(Vector2 progress) do
		         float delay = 0      // The delay in milliseconds
		         float duration = 300 // The duration in milliseconds
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress)
				
	importance:0 animateValue: Vector2 from
		         Vector2 to
		         stored void(Vector2 progress) do
		         float delay = 0      // The delay in milliseconds
		         float duration = 300 // The duration in milliseconds
		         EaseFunction ease
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress, ease)
				
	importance:0 animateValue: Color from
		         Color to
		         stored void(Color progress) do
		         float delay = 0      // The delay in milliseconds
		         float duration = 300 // The duration in milliseconds
		add InterpolateAnimation startTime:Time.now+delay, duration, do:do(from interpolateTo target:to, progress)
				
	global defer: stored void() do
		add DelayAnimation startTime:Time.now, do
		
struct float
	// Animate the float to a target value over a given period of time	
	inline animateTo: float target        // The target value to animate to
		              float delay = 0      // The delay before the animation starts in milliseconds
		              float duration = 300 // The duration of the animation in milliseconds
		fx.animateValue this, target, delay, duration, this = .
	
	// Animate the float to a target value over a given period of time	
	inline animateTo: float target        // The target value to animate to
		              float delay = 0      // The delay before the animation starts in milliseconds
		              float duration = 300 // The duration of the animation in milliseconds
		              EaseFunction ease   // The easing function to apply
		fx.animateValue this, target, delay, duration, ease, this = .
		
struct Vector2
	// Animate the vector to a target vector over a given period of time
	inline animateTo: Vector2 target      // The target vector to animate to
		              float delay = 0      // The delay before the animation starts in milliseconds
		              float duration = 300 // The duration of the animation in milliseconds
		fx.animateValue this, target, delay, duration, this.x = .x; this.y = .y

	// Animate the vector to a target vector over a given period of time
	inline animateTo: Vector2 target      // The target vector to animate to
		              float delay = 0      // The delay before the animation starts in milliseconds
		              float duration = 300 // The duration of the animation in milliseconds
		              EaseFunction ease   // The easing function to apply
		fx.animateValue this, target, delay, duration, ease, this.x = .x; this.y = .y
		
Color
	// Animate the color to a target vector over a given period of time
	inline animateTo: Color target        // The target color to animate to
		              float delay = 0      // The delay before the animation starts in milliseconds
		              float duration = 300 // The duration of the animation in milliseconds
		fx.animateValue this, target, delay, duration, this = .

transient global skipInit unit audio
	global importance:4 playSound: Sound sound
		              float delay = 0 // The delay before the sound starts in milliseconds
		              bool needsToBeCertain = false
		if needsToBeCertain and not input.isCertain then return
		
		if Time.ticks == 0
			fx.add PlaySoundAnimation startTime:math.ceil(Time.now+core.frameTime)+delay, sound
		else
		if delay
			fx.add PlaySoundAnimation startTime:Time.now+delay, sound
		else
			sound.play	
				
	global importance:4 static playSound: Sound sound
		              nocolon float at = 0 // The time at which the sound starts in milliseconds
		              bool needsToBeCertain = false
		if needsToBeCertain and not input.isCertain then return
		if Time.now >= at and Time.now < math.floor at + core.frameTime
			sound.play
				
internal Animation
	float startTime // The time at which the animation starts in milliseconds
	float duration  // The duration of the animation in milliseconds
	Object object
	tick: float progress, float time
	
internal Animation FadeAnimation
	float startValue, delta
	bool removeWhenDone
	tick(float progress, float time) 
		object.alpha = startValue + delta * progress
		if progress >= 1 and removeWhenDone then Framework.objects.remove object
		
internal Animation MoveAnimation
	Vector2 startValue, delta
	tick(float progress, float time) object.position = startValue + delta * progress
		
internal Animation ScaleAnimation
	implicit Vector2 startValue
	implicit Vector2 delta
	tick(float progress, float time) object.size = startValue + delta * progress
	
internal Animation RotateAnimation
	implicit float startValue
	implicit float delta
	tick(float progress, float time) object.angle = startValue + delta * progress
	
internal Animation FadeSoundAnimation
	float startValue, delta
	Sound sound
	tick(float progress, float time)
		if sound == null then return
		sound.volume = startValue + delta * progress
		if progress >= 1 then sound.stop
			
internal Animation PlaySoundAnimation
	Sound sound
	tick(float progress, float time) sound.play
	
internal Animation DelayAnimation
	void(Object object) do
	tick(float progress, float time) do(object)
	
internal Animation InterpolateAnimation
	void(float progress, float time) do
	tick(float progress, float time) do(progress, time)

internal Animation BezierAnimation
	Vector2[] points
	float smoothness = 1.0
	bool removeWhenDone
	tick(float progress, float time) 
		object.position = getPointOnBezierCurve(points, progress, smoothness)
		if progress >= 1 and removeWhenDone then Framework.objects.remove object

	static getPointOnBezierCurve: Vector2[] points, float progress, float smoothness = 1.0
		// Handle edge cases
		if points.length == 0	then return Vector2.Zero
		if points.length == 1	then return points[0]
		if progress <= 0	then return points[0]
		if progress >= 1	then return points.last
		
		// For 2 points, just use linear interpolation
		if points.length == 2
			return points[0] + (points[1] - points[0]) * progress
		
		// Calculate tangent vectors for each point
		Vector2[] tangents
		for points.length as i
			Vector2 tangent
			if i == 0
				// First point: tangent points straight toward the next point (no twist at start)
				tangent = (points[1] - points[0]).normalize
			else if i == points.length - 1
				// Last point: tangent points straight from the previous point (no twist at end)
				tangent = (points[i] - points[i-1]).normalize
			else
				// Interior points: use direction from previous to next point for smoothness
				tangent = (points[i+1] - points[i-1]).normalize
			tangents.add tangent
		
		// Calculate control point distances based on smoothness and segment lengths
		float[] distances
		for points.length - 1 as i
			float segmentLength = points[i].distanceTo(points[i+1])
			float controlDistance = segmentLength * smoothness * 0.3 // Scale factor for control point distance
			distances.add controlDistance
		
		// Find which segment the progress falls into
		float totalProgress = progress * (points.length - 1)
		int segmentIndex = math.floor(totalProgress)
		if segmentIndex >= points.length - 1 then segmentIndex = points.length - 2
		
		float localProgress = totalProgress - segmentIndex
		
		// Get the four control points for the cubic Bézier segment
		Vector2 p0 = points[segmentIndex]
		Vector2 p3 = points[segmentIndex + 1]
		
		// Special handling for first and last segments to ensure perfectly straight starts/ends
		Vector2 p1, p2
		float distanceFactor = segmentIndex == 0  ? .01 : 1
		p1 = p0 + tangents[segmentIndex] * distances[segmentIndex] * (segmentIndex == 0  ? .1 : 1)
		p2 = p3 - tangents[segmentIndex + 1] * distances[segmentIndex] * (segmentIndex == points.length - 2 ? .1 : 1)
		
		// Evaluate cubic Bézier curve: B(t) = (1-t)³P₀ + 3(1-t)²tP₁ + 3(1-t)t²P₂ + t³P₃
		float t = localProgress
		float oneMinusT = 1.0 - t
		float oneMinusT2 = oneMinusT * oneMinusT
		float oneMinusT3 = oneMinusT2 * oneMinusT
		float t2 = t * t
		float t3 = t2 * t
		
		Vector2 result = p0 * oneMinusT3 + 
		                 p1 * (3.0 * oneMinusT2 * t) + 
		                 p2 * (3.0 * oneMinusT * t2) + 
		                 p3 * t3
		
		return result
