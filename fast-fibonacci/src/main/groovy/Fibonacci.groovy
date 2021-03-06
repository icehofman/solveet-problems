/**
 * Solucion completa y test en: https://github.com/rchavarria/solveet-problems/tree/master/fast-fibonacci
 */
class Fibonacci {
	
	def recursive(n) {
		if(n == 0) 0
    	else if(n == 1) 1
    	else recursive(n - 1) + recursive(n - 2)
	}

	def iterative(n) {
		if(n == 0) 0
    	else if(n == 1) 1

		def cache = [0, 1]
		(2..n).each {
			cache << (cache[it - 1] + cache[it - 2] as BigInteger)
		}

		cache[n]
	}

	def limitedIterative(n) {
		if(n == 0) 0
    	else if(n == 1) 1
		
		def limitedCache = [0, 1]
		(2..n + 1).each {
			def tmp = limitedCache[0]
			limitedCache[0] = (limitedCache[1] + tmp as BigInteger)
			limitedCache[1] = tmp
		}

		limitedCache[0]
	}

	def memoized(n) {
		privateMemoized.call(n)
	}

	def privateMemoized = { n ->
		if(n == 0) 0
    	else if(n == 1) 1
    	else privateMemoized.call(n - 1) + privateMemoized.call(n - 2) as BigInteger
	}.memoize()

	def trampolined(n) {
		privateTrampolined.trampoline(n, 0, 1)
	}

	def privateTrampolined = { n, a, b -> 
		if(n == 0) a
		else privateTrampolined.trampoline( n - 1, b, (a + b as BigInteger))
	}.trampoline()
}