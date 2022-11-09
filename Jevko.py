# Generated automatically with "cito". Do not edit.

class Main:

	@staticmethod
	def get_message():
		parser = JevkoParser()
		str = parser.parse("a [b] c").to_string()
		print(str)

class JevkoParser:

	def __init__(self):
		self._escaper = 96
		self._opener = 91
		self._closer = 93

	def parse(self, str):
		parents = []
		parent = Jevko()
		prefix = ""
		h = 0
		is_escaped = False
		line = 1
		column = 1
		i = 0
		while i < len(str):
			c = ord(str[i])
			if is_escaped:
				if c == self._escaper or c == self._opener or c == self._closer:
					is_escaped = False
				else:
					raise Exception(f"Invalid digraph ({self._escaper}{c}) at {line}:{column}!")
			elif c == self._escaper:
				prefix = prefix + str[h:h + i - h]
				h = i + 1
				is_escaped = True
			elif c == self._opener:
				jevko = Jevko()
				sub = Subjevko()
				sub.set_prefix(prefix + str[h:h + i - h])
				sub.set_jevko(jevko)
				parent.get_subjevkos().append(sub)
				prefix = ""
				h = i + 1
				parents.append(parent)
				parent = jevko
			elif c == self._closer:
				parent.set_suffix(prefix + str[h:h + i - h])
				prefix = ""
				h = i + 1
				if len(parents) < 1:
					raise Exception(f"Unexpected closer ({self._closer}) at {line}:{column}!")
				parent = parents.pop()
			if c == 10:
				line += 1
				column = 1
			else:
				column += 1
			i += 1
		if is_escaped:
			raise Exception(f"Unexpected end after escaper ({self._escaper})!")
		if len(parents) > 0:
			raise Exception(f"Unexpected end: missing {len(parents)} closer(s) ({self._closer})!")
		parent.set_suffix(prefix + str[h:])
		return parent

class Jevko:
	def __init__(self):
		self._subjevkos = []
		self._suffix = ""

	def get_subjevkos(self):
		return self._subjevkos

	def set_suffix(self, value):
		self._suffix = value

	def to_string(self):
		ret = ""
		for sub in self._subjevkos:
			ret = f"{ret}{sub.get_prefix()}[{sub.get_jevko().to_string()}]"
		return ret + self._suffix

class Subjevko:

	def get_prefix(self):
		return self._prefix

	def get_jevko(self):
		return self._jevko

	def set_prefix(self, value):
		self._prefix = value

	def set_jevko(self, value):
		self._jevko = value

Main.get_message()