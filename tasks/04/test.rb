require '.\task04.rb'

var = Asm.asm do
  mov ax, 40
  mov bx, 32
  label cycle
  cmp ax, bx
  je finish
  jl asmaller
  dec ax, bx
  jmp cycle
  label asmaller
  dec bx, ax
  jmp cycle
  label finish
end

p var