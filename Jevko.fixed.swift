public class Main
{
	public static func getMessage() throws
	{
		var parser = JevkoParser()
		let str : String = try parser.parse("a [b] c").toString()
		print(str)
	}
}

public class JevkoParser
{
	private var escaper : Int = 96
	private var opener : Int = 91
	private var closer : Int = 93

	public func parse(_ str : String) throws -> Jevko
	{
		var parents : [Jevko] = []
		var parent = Jevko()
		var prefix : String = ""
		var h : Int = 0
		var isEscaped : Bool = false
		var line : Int = 1
		var column : Int = 1
		var i : Int = 0
		while i < str.count {
			let c : Int = ciStringCharAt(str, i)
			if isEscaped {
				if c == self.escaper || c == self.opener || c == self.closer {
					isEscaped = false
				}
				else {
					throw CiError.error("Invalid digraph (\(self.escaper)\(c)) at \(line):\(column)!")
				}
			}
			else if c == self.escaper {
				prefix = prefix + ciStringSubstring(str, h).prefix(i - h)
				h = i + 1
				isEscaped = true
			}
			else if c == self.opener {
				var jevko = Jevko()
				var sub = Subjevko()
				sub.prefix = prefix + ciStringSubstring(str, h).prefix(i - h)
				sub.jevko = jevko
				parent.subjevkos.append(sub)
				prefix = ""
				h = i + 1
				parents.append(parent)
				parent = jevko
			}
			else if c == self.closer {
				parent.suffix = prefix + ciStringSubstring(str, h).prefix(i - h)
				prefix = ""
				h = i + 1
				if parents.count < 1 {
					throw CiError.error("Unexpected closer (\(self.closer)) at \(line):\(column)!")
				}
				parent = parents.removeLast()
			}
			if c == 10 {
				line += 1
				column = 1
			}
			else {
				column += 1
			}
			i += 1
		}
		if isEscaped {
			throw CiError.error("Unexpected end after escaper (\(self.escaper))!")
		}
		if parents.count > 0 {
			throw CiError.error("Unexpected end: missing \(parents.count) closer(s) (\(self.closer))!")
		}
		parent.suffix = prefix + ciStringSubstring(str, h)
		return parent
	}
}

public class Jevko
{
	public var subjevkos : [Subjevko] 
	public var suffix : String

  init() {
    subjevkos = []
    suffix = ""
  }

	public func toString() -> String
	{
		var ret : String = ""
		for sub in self.subjevkos {
			ret = "\(ret)\(sub.prefix)[\(sub.jevko.toString())]"
		}
		return ret + self.suffix
	}
}

public class Subjevko
{
	public var prefix : String
	public var jevko : Jevko

  init() {
    prefix = ""
    jevko = Jevko()
  }
}

public enum CiError : Error
{
	case error(String)
}

fileprivate func ciStringCharAt(_ s: String, _ offset: Int) -> Int
{
	return Int(s.unicodeScalars[s.index(s.startIndex, offsetBy: offset)].value)
}

fileprivate func ciStringSubstring(_ s: String, _ offset: Int) -> Substring
{
	return s[s.index(s.startIndex, offsetBy: offset)...]
}

try Main.getMessage()