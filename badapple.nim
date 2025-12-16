import osproc, strutils, strformat, os

const 
  ASCII_CHARS = " .:-=+*#%@"
  WIDTH = 80
  HEIGHT = 40

proc downloadVideo(url: string) =
  echo "Downloading video..."
  discard execCmd(&"yt-dlp -f worst -o badapple.mp4 '{url}'")

proc rgbToAscii(r, g, b: int): char =
  let brightness = (r + g + b) div 3
  let index = brightness * (ASCII_CHARS.len - 1) div 255
  result = ASCII_CHARS[index]

proc extractAndDisplayFrame(time: float) =
  let cmd = &"ffmpeg -ss {time:.2f} -i badapple.mp4 -vframes 1 -vf scale={WIDTH}:{HEIGHT} -f rawvideo -pix_fmt rgb24 - 2>/dev/null"
  
  let (pixels, exitCode) = execCmdEx(cmd)
  
  if exitCode == 0 and pixels.len > 0:
    stdout.write("\e[2J\e[H")
    
    for y in 0..<HEIGHT:
      for x in 0..<WIDTH:
        let idx = (y * WIDTH + x) * 3
        if idx + 2 < pixels.len:
          let r = pixels[idx].ord
          let g = pixels[idx + 1].ord
          let b = pixels[idx + 2].ord
          stdout.write(rgbToAscii(r, g, b))
      stdout.write("\n")
    stdout.flushFile()

when isMainModule:
  let url = if paramCount() > 0: paramStr(1) else: "https://youtu.be/FtutLA63Cp8"
  downloadVideo(url)
  
  const fps = 10.0
  const duration = 30.0
  var time = 0.0
  
  while time < duration:
    extractAndDisplayFrame(time)
    sleep(int(1000.0 / fps))
    time += 1.0 / fps
