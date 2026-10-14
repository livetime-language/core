Please upgrade the code in @src to the new LiveTime syntax. Make sure the app compiles. If you encounter additional outdated syntax that needs to be updated, append them to this list.

Before	After
for start to end as x	for x = start to end
for start to end	for i = start to end
for 3 as r	for r to 3
for end	for end
for list.length backwards as item	for item to list.length step -1
for list as item	for item in list
for list	for list
for vector cells[pos]	for vector cells[.]
if a > b: print "Hello"	if a > b then print "Hello"
Platform	system
where	filter:
orderBy	sortBy
select	map
audio	sounds
contains	includes
Time.frame	Time.ticks
data.	media.
DateTime	Date
isInsideRectangle	insideRectangle
drawImage position:{0,0}	drawImage pos:{0,0}
ParticleSystem(position:)	ParticleSystem(position:) (unchanged, does not take pos:)
players	app.players
me	this
