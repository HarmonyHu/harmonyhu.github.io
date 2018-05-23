include Math
 
def func(x)
	1/(1+E**(-x))
end

def d_func(x)  #func的导数
	func(x) * (1-func(x))
end

$b1 = 0.35
$b2 = 0.60
$i1 = 0.05
$i2 = 0.10
$w1 = 0.15
$w2 = 0.20
$w3 = 0.25
$w4 = 0.30
$w5 = 0.40
$w6 = 0.45
$w7 = 0.50
$w8 = 0.55
$net_h1 = 0
$net_h2 = 0
$out_h1 = 0
$out_h2 = 0
$net_o1 = 0
$net_o2 = 0
$out_o1 = 0
$out_o2 = 0
$pre_o1 = 0.01
$pre_o2 = 0.99
$E_total = 0
$w1_new = 0
$w2_new = 0
$w3_new = 0
$w4_new = 0
$w5_new = 0
$w6_new = 0
$w7_new = 0
$w8_new = 0

def total_func()
def calc_net_h1()
  $net_h1 = $w1*$i1 + $w2*$i2 + $b1
end

def calc_net_h2()
  $net_h2 = $w3*$i1 + $w4*$i2 + $b1
end

def calc_out_h1()
  calc_net_h1()
  $out_h1 = func($net_h1)
end

def calc_out_h2()
  calc_net_h2()
  $out_h2 = func($net_h2)
end

def calc_net_o1()
  calc_out_h1
  calc_out_h2
  $net_o1 = $w5*$out_h1 + $w6*$out_h2 + $b2
end

def calc_net_o2()
  calc_out_h1
  calc_out_h2
  $net_o2 = $w7*$out_h1 + $w8*$out_h2 + $b2
end

def calc_out_o1()
  calc_net_o1
  $out_o1 = func($net_o1)
end

def calc_out_o2()
  calc_net_o2
  $out_o2 = func($net_o2)
end

def calc_E_total()
  calc_out_o1
  calc_out_o2
  $E_total = 0.5*(($pre_o1-$out_o1)**2 + ($pre_o2-$out_o2)**2)
end

def calc_af_E_out_o1()
  $af_E_out_o1 = $out_o1 - $pre_o1
end

def calc_af_E_out_o2()
  $af_E_out_o2 = $out_o2 - $pre_o2
end

def calc_af_out_o1_net_o1()
  $af_out_o1_net_o1 = $out_o1*(1-$out_o1)
end

def calc_af_out_o2_net_o2()
  $af_out_o2_net_o2 = $out_o2*(1-$out_o2)
end

def calc_af_net_o1_w5()
  $af_net_o1_w5 = $out_h1
end

def calc_af_net_o1_w6()
  $af_net_o1_w6 = $out_h2
end

def calc_af_net_o2_w7()
  $af_net_o1_w7 = $out_h1
end

def calc_af_net_o2_w8()
  $af_net_o1_w8 = $out_h2
end

calc_E_total
puts "out_o1:"+$out_o1.to_s
puts "out_o2:"+$out_o2.to_s
puts "E_total:"+$E_total.to_s

calc_af_E_out_o1()
calc_af_E_out_o2()
calc_af_out_o1_net_o1()
calc_af_out_o2_net_o2()
calc_af_net_o1_w5()
calc_af_net_o1_w6()
calc_af_net_o2_w7()
calc_af_net_o2_w8()

$af_E_total_w5 = $af_E_out_o1*$af_out_o1_net_o1*$af_net_o1_w5
$af_E_total_w6 = $af_E_out_o1*$af_out_o1_net_o1*$af_net_o1_w6
$af_E_total_w7 = $af_E_out_o2*$af_out_o2_net_o2*$af_net_o1_w7
$af_E_total_w8 = $af_E_out_o2*$af_out_o2_net_o2*$af_net_o1_w8
puts "af_E_total_w5:"+$af_E_total_w5.to_s
puts "af_E_total_w6:"+$af_E_total_w6.to_s
puts "af_E_total_w7:"+$af_E_total_w7.to_s
puts "af_E_total_w8:"+$af_E_total_w8.to_s

$w5_new = $w5 - 0.5 * $af_E_total_w5
$w6_new = $w6 - 0.5 * $af_E_total_w6
$w7_new = $w7 - 0.5 * $af_E_total_w7
$w8_new = $w8 - 0.5 * $af_E_total_w8
puts "w5_new:"+$w5_new.to_s
puts "w6_new:"+$w6_new.to_s
puts "w7_new:"+$w7_new.to_s
puts "w8_new:"+$w8_new.to_s

def calc_af_net_o1_out_h1()
  $af_net_o1_out_h1 = $w5
end

def calc_af_net_o1_out_h2()
  $af_net_o1_out_h2 = $w6
end

def calc_af_net_o2_out_h1()
  $af_net_o2_out_h1 = $w7
end

def calc_af_net_o2_out_h2()
  $af_net_o2_out_h2 = $w8
end

def calc_af_E_total_out_h1()
  calc_af_net_o1_out_h1
  calc_af_net_o2_out_h1
  $af_E_total_out_h1 = $af_net_o1_out_h1 * $af_out_o1_net_o1 * $af_E_out_o1 +
                         $af_net_o2_out_h1 * $af_out_o2_net_o2 * $af_E_out_o2
end

def calc_af_E_total_out_h2()
  calc_af_net_o1_out_h2
  calc_af_net_o2_out_h2
  $af_E_total_out_h2 = $af_net_o1_out_h2 * $af_out_o1_net_o1 * $af_E_out_o1 +
                         $af_net_o2_out_h2 * $af_out_o2_net_o2 * $af_E_out_o2
end

def calc_af_out_h1_net_h1()
  $af_out_h1_net_h1 = $out_h1*(1-$out_h1)
end

def calc_af_out_h2_net_h2()
  $af_out_h2_net_h2 = $out_h2*(1-$out_h2)
end

def calc_af_net_h1_w1()
  $af_net_h1_w1 = $i1
end

def calc_af_net_h1_w2()
  $af_net_h1_w2 = $i2
end

def calc_af_net_h2_w3()
  $af_net_h2_w3 = $i1
end

def calc_af_net_h2_w4()
  $af_net_h2_w4 = $i2
end

calc_af_E_total_out_h1
calc_af_E_total_out_h2
calc_af_out_h1_net_h1
calc_af_out_h2_net_h2
calc_af_net_h1_w1
calc_af_net_h1_w2
calc_af_net_h2_w3
calc_af_net_h2_w4
  
def calc_af_E_w1()
  $af_E_w1 = $af_E_total_out_h1 * $af_out_h1_net_h1 *$af_net_h1_w1
  puts "af_E_w1:"+$af_E_w1.to_s
end

def calc_af_E_w2()
  $af_E_w2 = $af_E_total_out_h1 * $af_out_h1_net_h1 *$af_net_h1_w2
  puts "af_E_w2:"+$af_E_w2.to_s
end

def calc_af_E_w3()
  $af_E_w3 = $af_E_total_out_h2 * $af_out_h2_net_h2 *$af_net_h2_w3
  puts "af_E_w3:"+$af_E_w3.to_s
end

def calc_af_E_w4()
  $af_E_w4 = $af_E_total_out_h2 * $af_out_h2_net_h2 *$af_net_h2_w4
  puts "af_E_w4:"+$af_E_w4.to_s
end

calc_af_E_w1
calc_af_E_w2
calc_af_E_w3
calc_af_E_w4

$w1_new = $w1 - 0.5 * $af_E_w1
$w2_new = $w2 - 0.5 * $af_E_w2
$w3_new = $w3 - 0.5 * $af_E_w3
$w4_new = $w4 - 0.5 * $af_E_w4
puts "w1_new:"+$w1_new.to_s
puts "w2_new:"+$w2_new.to_s
puts "w3_new:"+$w3_new.to_s
puts "w4_new:"+$w4_new.to_s
end

for $index in 0...10000
	total_func
	$w1 = $w1_new
	$w2 = $w2_new
	$w3 = $w3_new
	$w4 = $w4_new
	$w5 = $w5_new
	$w6 = $w6_new
	$w7 = $w7_new
	$w8 = $w8_new
end