# The LiveTime Standard Library
These are the available classes and functions. NEVER call any other functions!
```
class int
	const int maxValue
	const int minValue
	int remainder: int value
	string toString:
	string format: int minIntegerDigits, bool grouping
	int abs:
	int shiftLeft: int count
	int shiftRight: int count
	int bitwiseOr: int value
	int bitwiseAnd: int value
	int limit: int from, int to
	int atLeast: int value
	int atMost: int value

class float
	static float maxValue:
	static float minValue:
	static float infinity:
	float remainder: float value
	string toString:
	string format: int fractionDigits, int minIntegerDigits, bool grouping
	float abs:
	float sign:
	int ceil:
	int floor:
	int round:
	float atLeast: float value
	float atMost: float value
	bool isApproximately: float value, float epsilon
	float moveTowards: float value, float speed

class string
	int length:
	string toUpperCase:
	string toLowerCase:
	int toInt:
	int toFloat:
	dynamic parseJson:
	int parseInt: int radix
	string[] split: string seperator
	bool startsWith: string str
	bool endsWith: string str
	int indexOf: string str
	int indexOf: string str, int startPos
	int lastIndexOf: string str
	int lastIndexOf: string str, int startPos
	bool contains: string str
	string substring: int from
	string substring: int from, int to
	string trim:
	string capitalize:

class List<T>
	void add: T item
	void addRange: T[] items
	void insert: T item, int index
	void insert: T item, T after
	void remove: T item
	void removeAt: int index
	void removeRange: int from, int to
	void removeWhere: bool(T a) condition
	T removeFirstWhere: bool(T a) condition
	void ensure: T item
	void ensure: T[] items
	bool contains: T item
	bool containsAny: T[] list
	bool containsNone: T[] list
	int indexOf: T item
	T pop:
	T popAt: int index
	T popWhere: bool(T a) condition
	T popFirst:
	void clear:
	T random:
	T randomWhere: bool(T a) condition
	T popRandom:
	T popRandomWhere: bool(T a) condition
	T[] reverse:
	void moveToBack: T item
	void moveToFront: T item
	T[] orderBy: float(T a) expression
	T[] orderBy: float(T it) expression, string(T it) thenBy
	T[] orderBy: float(T a) expression, SortingOrder order
	bool any: bool(T a) predicate
	bool none: bool(T a) predicate
	bool all: bool(T a) predicate
	TValue[] select: TValue(T it, int i) selector
	T find: bool(T a) condition
	int indexWhere: bool(T a) condition, int startIndex
	T[] where: bool(T a) condition
	T[] take: int count
	int total: int(T it) selector
	T[] shuffle:
	float min: float(T a) selector, float threshold, float default
	float max: float(T a) selector, float threshold, float default
	int minIndex: float(T a) selector, int startIndex, float threshold
	int maxIndex: float(T a) selector, int startIndex, float threshold
	T withMin: float(T a) selector, float threshold
	T withMax: float(T a) selector, float threshold
	T[] intersectWith: T[] other
	T first:
	T last:

class Map<TKey, TValue>
	void remove: TKey key
	bool has: TKey key
	void clear:
	int length:
	void removeWhere: bool(TValue it) condition

class object
	static string toJson: any value

class Set<T>
	void add: T value
	void remove: T value
	bool has: T value
	void clear:
	int length:

static class math
	static float abs: float value
	static float sign: float value
	static float sqrt: float value
	static float moveTowards: float value, float targetValue, float speed
	static int floor: float value
	static int ceil: float value
	static int round: float value
	static float min: float a, float b
	static float max: float a, float b
	static float sin: Angle angle
	static float cos: Angle angle
	static float tan: Angle angle
	static Angle atan2: float y, float x
	static float log: float value
	static float log2: float value
	static float log10: float value
	static float pow: float base, float exponent
	static float exp: float exponent
	static Angle getAngleForVector: Vector2 vector
	static Vector2 getVectorForAngle: Angle angle, float radius
	static Vector2 intersectLines: Vector2 startA, Vector2 endA, Vector2 startB, Vector2 endB, LineType typeA, LineType typeB

class Time
	int milliseconds:
	int seconds:
	int minutes:
	int hours:
	int totalSeconds:
	int totalMinutes:
	int totalHours:
	int totalDays:
	int totalWeeks:
	static Time now
	static int frame:

class Vector2
	static Vector2 none:
	static Vector2 minValue:
	static Vector2 maxValue:
	static Vector2 zero:
	string toString:
	Vector2 clone:
	float length:
	Vector2 sign:
	float lengthSquared:
	Vector2 orthogonal:
	Vector2 invert:
	IntVector2 round:
	IntVector2 floor:
	IntVector2 ceil:
	Vector2 abs:
	float distanceTo: Vector2 value
	float manhattanDistanceTo: Vector2 value
	Angle angleTo: Vector2 value
	Vector2 normalize:
	void moveTowards: Vector2 targetPosition, float speed, void() onReachedTarget
	bool isInsideRectangle: Vector2 center, Vector2 size
	bool isInsidePolygon: Vector2[] poly
	bool in: Rect rectangle
	float dot: Vector2 value
	float cross: Vector2 value

class Color
	string hex

static class audio
	global void playSound: Sound sound, Time delay, bool needsToBeCertain
	global void playSound: Sound sound, Time at, bool needsToBeCertain

class IntVector2
	static IntVector2 none:
	static IntVector2 zero:
	IntVector2 clone:
	string toString:
	float length:
	IntVector2 orthogonal:
	IntVector2 inverse:
	IntVector2 abs:
	float distanceTo: IntVector2 value
	int manhattanDistanceTo: IntVector2 value
	bool isInsideRectangle: IntVector2 center, IntVector2 size
	Angle angleTo: IntVector2 value

class Angle
	Angle rotateTowards: Angle value, Angle speed
	Angle normalize:

class Direction
	const Direction Up
	const Direction Right
	const Direction Down
	const Direction Left
	const Direction None
	const Direction[] primaryDirections
	const Direction[] diagonalDirections
	const Direction[] horizontalDirections
	const Direction[] verticalDirections
	const Direction[] allDirections
	string name
	IntVector2 vector
	Angle angle

class Rect
	Vector2 position
	Vector2 size
	bool contains: Vector2 position
	bool intersectsWith: Vector2 position, Vector2 size

class Grid<T>
	TValue[] select: TValue(T it) selector
	bool all: bool(T a) predicate
	bool any: bool(T a) predicate
	T[] where: bool(T a) predicate
	bool isValid: IntVector2 pos

static class graphics
	static DrawingOrder drawingOrder
	global void drawImage: Image image, Vector2 position, Vector2 size, Player[] visibleFor, Player[] clickableBy, int frame, int layer, float alpha, Color color, Angle angle, bool flipX, bool flipY, Vector2 clickableMargin, bool showClickableArea, Key hotkey, void(Touch touch) onClick
	global float drawText: string text, Vector2 position, Vector2 size, Color color, HorizontalAlignment align, VerticalAlignment valign, FontStyle style, Font font, Color outlineColor, int outlineWidth, int layer, float alpha, Angle angle, Player[] visibleFor, Player[] clickableBy, Vector2 clickableMargin, bool showClickableArea, Key hotkey, TextOverflow overflow, float maxWidth, float lineHeight, void(Touch touch) onClick
	global void drawRectangle: Vector2 position, Vector2 size, Color color, Color outlineColor, int outlineWidth, Player[] visibleFor, int layer, float alpha, HorizontalAlignment align, VerticalAlignment valign
	global void drawRoundedRectangle: Vector2 position, Vector2 size, int radius, Color color, Color outlineColor, int outlineWidth, Player[] visibleFor, int layer, float alpha, HorizontalAlignment align, VerticalAlignment valign
	global void drawCircle: Vector2 position, Vector2 size, Color color, Color outlineColor, int outlineWidth, Angle startAngle, Angle angle, RotationDirection direction, Player[] visibleFor, int layer, float alpha
	global void drawLine: Vector2 from, Vector2 to, Color color, int width, Player[] visibleFor, int layer, float alpha
	global void drawLines: Vector2[] points, Vector2 position, Color color, int width, bool smooth, Player[] visibleFor, int layer, float alpha
	global void drawPolygon: Vector2[] points, Vector2 position, Color color, Color outlineColor, int outlineWidth, bool smooth, Player[] visibleFor, int layer, float alpha
	global void drawVideo: Player player, Vector2 position, Vector2 size, VideoShape shape, Player[] visibleFor

class Touch
	Player by
	bool isDown
	Vector2 position:
	void markAsHandled:

static class input
	global void onTouchDown: Vector2 position, Vector2 size, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, HorizontalAlignment align, VerticalAlignment valign, void(Touch touch) do
	global void onTouchDown: Vector2 position, float radius, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, void(Touch touch) do
	global void onTouchOver: Vector2 position, Vector2 size, Player[] by, Cursor cursor, bool showClickableArea, bool markAsHandled, HorizontalAlignment align, VerticalAlignment valign, void(Touch touch) do
	global void onTouchMove: Touch touch, bool triggeredOnTouchDown, void(Touch touch) do
	global void onTouchUp: Touch touch, bool markAsHandled, void(Touch touch) do

```
