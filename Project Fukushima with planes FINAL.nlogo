globals [
          halflife ;half-life of iodine 131, it 8.025 days
          dist ;distance from the origin of the puff
          concentration ;concentration of iodine particles
          factor ;empirical factor for gaussian-plume for atmosphere instability 0.89 for low variability 0.92 for moderate to strong
        ]

breed [ particles particle ] ;simulate particles of iodine 131
breed [ planes plane ] ;simulate planes in the sky


to setup ;initialization

  set halflife 100 ;set to 100%

  resize-world -310 310 -200 200 ;resize the world to the size of the .jpeg
  clear-all ;clear everything
  ask patches [ set pcolor black ]
  set-patch-size 1 ;change the size of patches to 1
  import-drawing "fukushima_ocean.jpg" ;import the map was copied from google map

  ;CREATION of PARTICLES
  ;---------------------
  create-particles 2000 [ ;create iodine particles
    ; then initialize their variables
    set color blue
    set size 8  ; easier to see
    setxy random-normal -127 0.1 random-normal -40 0.1 ;coordinates of fukushima in the map
    set heading wind-direction ;choose the direction of the wind with the slider
    set shape "dot" ;shape of the particles
  ]

  ;CREATION OF PLANES
  ;------------------
  create-planes 10 [ ;creation of randomly positioned planes heading to west
    set color black
    set size 10
    set shape "airplane"
    setxy random-xcor random-ycor
    set heading 270  ;to west
  ]
  create-planes 10 [ ;creation of randomly positioned planes heading to east
    set color black
    set size 10
    set shape "airplane"
    setxy random-xcor random-ycor
    set heading 90 ;to east
  ]

  reset-ticks ;set tick counter to 0
end ;end of initialization

to go

  ifelse stability-condition = 0.02 [set factor 0.89 ] [ set factor 0.92 ] ;change factor according to the chooser button
  if ticks = 78 [ stop ] ;end the run after 78 cycles/ticks

  ask particles [
    set dist distancexy -127 -40 ;calculate distance between fukushima (-127, 40) and the position of the particle (distancexy)
    rt random-normal 0 ( (stability-condition * (dist ^ factor)) ) ;empirical Gaussian-plume spreading sigma in width
    fd random-normal (wind-force) ( wind-force * ( dist ^ factor ) ) ;empirical Gaussia-plume spreading sigma in length

    move ;call of the function "move" to move the particles (see below)

    set halflife 99.6407655962586 ; for 1 hour probability --> halflife e ^ (T * 24 * 3600 * (- 9.9967 * 10 ^ -7) + ln 100) with T in day, for 1 hour the result is ~99.641%
    if random-float 100 > halflife [  die ] ;calculate probability and if the random is higher the particle dies

    ;CLOUD VISUALIZATION OF PARTICLES
    ;---------------------------------
    ;ARBITRARY CHOICE OF VARIABLES JUST TO LOOK NICE
    set concentration count particles in-radius 5 ;create a gradient of color to draw the cloud in the interface
      if concentration > 100 [set color red ]
      if concentration < 80 [ set color orange ]
      if concentration < 60 [ set color yellow ]
      if concentration < 40 [ set color green ]
      if concentration < 20 [ set color blue ]
      if concentration < 10 [ set color black ]
  ]

  ask planes [
    if any? particles-on patch-ahead 100 ;the plane checks if there are particles ahead of it
      [ lt 180 set color red ] ;if particle ahead of the plane U-Turn and change its color to red
      fd 20 ;speed of the plane
    if any? particles-on neighbors [ set color green set label "IRRADIATED" set label-color red]
    ;if there are particles in the 8 patches surrounding the plane it is irradiated and change its color to green with a label "irradiated"
  ]
  tick
end

to move  ;turtle procedure to move the particle
 fd random-normal wind-force stability-condition * ticks
end


@#$#@#$#@
GRAPHICS-WINDOW
227
16
856
426
-1
-1
1.0
1
10
1
1
1
0
1
1
1
-310
310
-200
200
1
1
1
ticks
5.0

BUTTON
5
11
68
44
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
12
166
45
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
19
62
157
107
stability-condition
stability-condition
0.14 0.06 0.02
1

SLIDER
7
114
224
147
wind-force
wind-force
0
0.1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
5
154
177
187
wind-direction
wind-direction
0
360
50.0
10
1
NIL
HORIZONTAL

PLOT
6
195
205
380
Iodine-131 Concentration
time (h)
%
0.0
240.0
0.0
100.0
true
false
"" ""
PENS
"Iodine-131" 1.0 0 -13345367 true "" "plot count particles / 20"

PLOT
877
50
1154
303
Airplanes status
Time (H)
Number of planes
0.0
10.0
0.0
20.0
true
true
"" ""
PENS
"Normal" 1.0 0 -16777216 true "" "plot count planes with [ color = black ]"
"U-Turn" 1.0 0 -2674135 true "" "plot count planes with [ color = red ]"
"Irradiated" 1.0 0 -14439633 true "" "plot count planes with [ color = green ]"

@#$#@#$#@
## WHAT IS IT?

The model tries to simulate the nuclear cloud (composed of Iodine 131 particles) after the first days of Fukushima Daiichi nuclear disaster that occurs the 11th of March 2011 in Japan and its potential impact on the air traffic.

## HOW IT WORKS

1. AGENT called "PARTICLES" in NetLogo:
---------------------------------------

It represents the IODINE-131 radioactive isotope. It is one of the most abundant particle released in the atmosphere after a nuclear disaster (like in Tchernobyl).

First, for the model, the released of Iodine-131 in the air is considered as a PUFF at Tick 0 (t0). The spread of the particles follows the Gaussian-Plume modelization.
For the Gaussian-Plume model you need to know the direction of the wind, the instability of the air (empirical value), the distance between the point at t0 and at the measured time. As distance increases so does the dispersion.
The spread follows a normal distribution, 
There exists an empirical formula where the sigma of the spread of particles is equal to:
- (factor of instability) * (distance from t0) ^ factor (0.92 or 0.89 depends of the factor)

This table summarizes this equation:
![alt text](instability_gaussian.jpg)


To represent the spread in width in NetLogo particles will turn following the normal distribution N(0, sigma), for 0 the particle follows the wind direction.

For the distribution in length (of the plume) same equation is applied but it's multiplied by the wind-force (the more the wind is strong the more the spread in length is too)

![alt text](puff_gaussian.jpg)


Half-Life of IODINE-131:
As a radioelement, IODINE-131 has a half-life that is 8.025 days. It means that every 8.025 days the concentration in IODINE-131 is divided by two. 

![alt text](halflife.gif)

ln(concentration at T0) / ln(concentration at T) = k * T, with k the decay constant
For IODINE-131 that constant is 9.9967×10^-7 per second

We will monitor the decrease of IODINE-131 in percentage with a plot in the interface window.



2. AGENT called "PLANES" in NetLogo:
---------------------------------------

Virtual airplanes are created (some heading to east and some heading to west).
When an airplane "sees" particles in front of it, it changes his course doing a U-turn and changing its color to red.
If an airplane goes through a patches containing a particle it is considered as contaminated. It gets the label "irradiated" and changes its color to green.

This modelization is pretty simple, but a more accurate model could be done using real data of flights in the area. It could possibly anticipate what an airplane would do in case of nuclear cloud in the area (changing destination airport, giving iodine pills to passengers...).




## HOW TO USE IT

- You choose the stability condition with a Slider:
0.14 (unstable)
0.06 (neutral)
0.02 (stable)

- The direction of the wind with a slider, knowing that 0 is North and 90 is east.
The 11th March in Fukushima the wind blows to north-east (~50°)

- IODINE-131 concentration plots: Quantity of IODINE in the atmosphere in percentage

- Airplane Status plot:
	- in Black : the number of airplanes not affected by the radioactive cloud
	- in Red : the number of airplanes doing a U-turn
	- in Green : the number of airplanes affected by radioactivity



## THINGS TO NOTICE



We consider that 1 tick is equal to 1 hour so :
For the half-life equation I had to calculate it manually for 1 hour and the result is 99.6407655962586

The probability that a particle disapears is:
             exponential ((T * 24 * 3600 * (- 9.9967 * 10 ^ -7) + ln 100))

For T = 8.025 days, the result is 50 % of course (for 1 hour it is 99.64)

Over 2000 particles the computation time starts to be pretty slow

The model was fit to be as close as possible from the real event after 48H



## THINGS TO TRY

Moving the instability factor

## EXTENDING THE MODEL

This model is a prototype and it has its own limitation:
	- The gaussian-plume is not the most complicated model existing
	- Once the wind direction is chosen you can not alter it
	- airplanes follow a really "dumb" path (just heading to east or west)
	- because of limitation of particles (computation time) it happens that an 	airplane cant see it is heading directly to the radioactive cloud and goes through it.
	- other explosion occured during the next hours and days and more radioactive elements were released in the atmosphere. This model only creates the first Puff.

You could predict the impact if an other nuclear plant disaster would occur on a different place in the world.

## NETLOGO FEATURES

N/A

## RELATED MODELS

I coded everything from scratch couldn't find a model close to this one, specially for the Gaussian-Plume modelization

For the code I followed the NetLogo Help and got some inspiration with the code studied during the courses with "sheep and wolves"

## CREDITS AND REFERENCES

Gaussian-Plume theory:  "Dispersion for point sources - CE 524 - February 2011" (pdf file)
http://home.engineering.iastate.edu/~leeuwen/CE%20524/Notes/Dispersion_Handout.pdf

Wikipedia : https://en.wikipedia.org/wiki/Fukushima_Daiichi_nuclear_disaster

IRSN official document : "Summary of the Fukushima accident's impact on the
environment in Japan, one year after the accident"
http://www.irsn.fr/en/publications/thematic/fukushima/documents/irsn_fukushima-environment-consequences_28022012.pdf



@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
