-- title:  Croco Craze
-- author: StinkerB06
-- desc:   Based off the popular Hasbro game
-- input:  keyboard
-- saveid: CrocoGameSB2K
GAME={frame=0; numTeeth=13; toothCount=0; mode=0;}
KEYcode={
	[0]=17; [1]=23; [2]=5; [3]=18; [4]=20; [5]=25; [6]=21;
	[7]=9; [8]=15; [9]=16; [10]=39; [11]=40; [12]=41;
}
Tstat={
	[0]=false; [1]=false; [2]=false; [3]=false; [4]=false;
	[5]=false; [6]=false; [7]=false; [8]=false; [9]=false;
	[10]=false; [11]=false; [12]=false;
}
-- This function originates from btco's "8 Bit Panda" game
function Iif(cond,t,f)
	if cond then return t else return f end
end
--
function exception(msg)
	trace(msg,6) exit()
end

-- This is used to distort the waveforms (see TIC function)
function bxor(a,b,bitDepth)
 local r=0
 for i=0,math.max(bitDepth,1)-1 do
  local x=(a/2)+(b/2)
  if x~= math.floor(x) then r=r+(2^i) end
  a=math.floor(a/2)
  b=math.floor(b/2)
 end
 return r
end
function distortWaves()
	local waveDistortRandom=math.random(0,1)*15
	for i=0,511 do
		poke4(0x1FFC8+i,bxor(peek4(0x1FFC8+i),waveDistortRandom,4))
	end
end
--

-- This is how the bad tooth is randomly chosen!
toothNo=math.random(0,math.min(GAME.numTeeth-1,12))
--
centerW=(120-(4*math.min(GAME.numTeeth,13)))
music(1)
function processGame(m)
	if m==0 then -- Title screen
		print("Press the spacebar or Enter to start!",1,84)
		print("Last time: "..(pmem(0)//60).." seconds",1,91)
		print("High score: "..(pmem(1)),1,98)
		print("2018 StinkerB06",1,130)
		spr(4,207,103,-1,2,0,0,2,2)
		map(0,0,13,5,120-52,30,0)
		if keyp(48) or keyp(50) then
			sfx(2)
			GAME.mode=1
		end
		if (key(64) and keyp(5)) then -- Clear PMEM
			sfx(0)
			for pmClear=0,254 do pmem(pmClear,0) end
		end
	elseif m==1 then -- Gameplay
		for tooth=0,math.min(GAME.numTeeth-1,12) do
			spr(Iif(Tstat[tooth],2,1),centerW+(8*tooth),84)
			spr(3,centerW+(8*tooth),92)
			if (key(KEYcode[tooth]) and (not Tstat[tooth])) then
				Tstat[tooth]=true
				GAME.toothCount=GAME.toothCount+1
			end
		end
		-- bad-tooth event code line
		if key(KEYcode[toothNo]) then
			local count=0
			for read=0,math.min(GAME.numTeeth-1,12) do
				count=(count+Iif(Tstat[read],1,0))
			end
			music(Iif(count==GAME.numTeeth,0,2),-1,-1,false)
			GAME.mode=2
		end
		--
		print("Survival score: "..(GAME.toothCount),1,1)
		print("Time: "..(GAME.frame//60).." seconds",1,8)
		GAME.frame=GAME.frame+1
	elseif m==2 then -- Game over
		local win="You did it!"
		local death="You got bitten by the crocodile!"
		local highScore=(GAME.toothCount>=pmem(1))
		print(Iif(GAME.toothCount==GAME.numTeeth,win,death),1,1)
		print("Press the spacebar or Enter to reset.",1,8)
		pmem(0,GAME.frame)
		pmem(1,Iif(highScore,GAME.toothCount,pmem(1)))
		if highScore==true then print("New high score!",1,15,math.random(11,15)) end
		if keyp(48) or keyp(50) then reset() end
	else exception("ERR: invalid state of GAME.mode") end
end
function TIC()
	local BGc=1
	cls(BGc)
	poke(0x3FF8,BGc)
	processGame(GAME.mode) -- This is inspiration from Panda
	-- For cheating! (remove the dash marks at the beginning)
	--print(toothNo+1,228,1)
	--distortWaves()
	--
end

-- StinkerB06 owns privledges to this cartridge. If anyone
-- tries to copy any of my carts, then they will be told on
-- NesBox if without permission.