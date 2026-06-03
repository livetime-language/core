global skipInit unit math
	init
		initDefaultRandomGenerator
		
	js void initDefaultRandomGenerator
		math.randomGenerator = Math.random
		
	js string generateRandomSeed:
		let crypto = !window.crypto && typeof(require) != "undefined" ? require("crypto") : window.crypto
		if(crypto) {
			let out = new Uint8Array(256);
			crypto.getRandomValues(out);
			return out.toString();
		}
		
	transient internal string randomSeed
	internal float randomValueIndex
	transient internal float[] randomValues
	
	internal recreateRandomValues
		let targetRandomValueIndex = randomValueIndex
		setRandomSeed randomSeed
		for targetRandomValueIndex
			randomFloat
	
	js void setRandomSeed: string seed
		math.randomSeed = seed
		math.randomValues = []
		math.randomValueIndex = 0
		
		// Seeding the random float generator in Javascript
		// https://stackoverflow.com/a/47593316
		function xmur3(str) {
		    for(var i = 0, h = 1779033703 ^ str.length; i < str.length; i++) {
		        h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
		        h = h << 13 | h >>> 19;
		    } return function() {
		        h = Math.imul(h ^ (h >>> 16), 2246822507);
		        h = Math.imul(h ^ (h >>> 13), 3266489909);
		        return (h ^= h >>> 16) >>> 0;
		    }
		}
		
		function sfc32(a, b, c, d) {
		    return function() {
		      a >>>= 0; b >>>= 0; c >>>= 0; d >>>= 0; 
		      var t = (a + b) | 0;
		      a = b ^ b >>> 9;
		      b = c + (c << 3) | 0;
		      c = (c << 21 | c >>> 11);
		      d = d + 1 | 0;
		      t = t + d | 0;
		      c = c + t | 0;
		      return (t >>> 0) / 4294967296;
		    }
		}
		
		function mulberry32(a) {
		    return function() {
		      var t = a += 0x6D2B79F5;
		      t = Math.imul(t ^ t >>> 15, t | 1);
		      t ^= t + Math.imul(t ^ t >>> 7, t | 61);
		      return ((t ^ t >>> 14) >>> 0) / 4294967296;
		    }
		}
		
		var seed = xmur3(seed);
		var rand = sfc32(seed(), seed(), seed(), seed());
		var rand = mulberry32(seed());
		
		math.randomGenerator = function() {
			let value
			if(math.randomValueIndex < math.randomValues.length) {
				value = math.randomValues[math.randomValueIndex]
				math.randomValueIndex++
			} else {
				value = rand()
				math.randomValues[math.randomValueIndex++] = value;
			}
			return value
		}

	// Generates a random integer
	global js float randomInteger: float from // The inclusive lower bound of the random integer
		                         float to // The exclusive upper bound of the random integer
		return from + Math.floor(math.randomGenerator() * (to-from))
	
	global js float random: float to = 1.0
		return math.randomGenerator() * to

	// Generates a random float
	global js float random: float from
		                    float to
		return from + math.randomGenerator() * (to-from)
