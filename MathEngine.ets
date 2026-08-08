// entry/src/main/ets/common/MathEngine.ets

// ==================== GCD & LCM ====================
export function gcd(a: number, b: number): number {
  let x = Math.abs(a);
  let y = Math.abs(b);
  while (y !== 0) {
    let temp = y;
    y = x % y;
    x = temp;
  }
  return x;
}

export function gcdMultiple(numbers: number[]): number {
  if (numbers.length === 0) return 0;
  let result = numbers[0];
  for (let i = 1; i < numbers.length; i++) {
    result = gcd(result, numbers[i]);
    if (result === 1) break;
  }
  return result;
}

export function lcm(a: number, b: number): number {
  if (a === 0 || b === 0) return 0;
  return Math.abs(a * b) / gcd(a, b);
}

export function lcmMultiple(numbers: number[]): number {
  if (numbers.length === 0) return 0;
  let result = numbers[0];
  for (let i = 1; i < numbers.length; i++) {
    result = lcm(result, numbers[i]);
  }
  return result;
}

// ==================== 质数 ====================
export function isPrime(num: number): boolean {
  if (num < 2) return false;
  if (num === 2) return true;
  if (num % 2 === 0) return false;
  for (let i = 3; i * i <= num; i += 2) {
    if (num % i === 0) return false;
  }
  return true;
}

export function filterPrimes(numbers: number[]): number[] {
  return numbers.filter(n => isPrime(n));
}

// ==================== 欧拉函数 ====================
export function eulerPhi(n: number): number {
  if (n <= 0) return 0;
  if (n === 1) return 1;
  
  let result = n;
  let num = n;
  for (let p = 2; p * p <= num; p++) {
    if (num % p === 0) {
      while (num % p === 0) num /= p;
      result -= result / p;
    }
  }
  if (num > 1) result -= result / num;
  return result;
}

export function getCoprimeNumbers(n: number): number[] {
  let result: number[] = [];
  for (let i = 1; i <= n; i++) {
    if (gcd(i, n) === 1) result.push(i);
  }
  return result;
}

// ==================== 模幂 ====================
export function fastPow(base: number, exp: number, mod: number): number {
  if (mod === 1) return 0;
  let b = ((base % mod) + mod) % mod;
  let result = 1;
  let e = exp;
  while (e > 0) {
    if (e & 1) result = (result * b) % mod;
    b = (b * b) % mod;
    e >>= 1;
  }
  return result;
}

// ==================== CRT ====================
function exgcd(a: number, b: number): { gcd: number, x: number, y: number } {
  if (b === 0) {
    return { gcd: Math.abs(a), x: 1, y: 0 };
  }
  let result = exgcd(b, a % b);
  return {
    gcd: result.gcd,
    x: result.y,
    y: result.x - Math.floor(a / b) * result.y
  };
}

export function crt(aList: number[], mList: number[]): { success: boolean, x?: number, M?: number, error?: string } {
  if (aList.length !== mList.length) {
    return { success: false, error: '余数数组和模数数组长度必须相同' };
  }
  if (aList.length === 0) {
    return { success: false, error: '请输入至少一个同余式' };
  }
  
  let M = 1;
  for (let m of mList) M *= m;
  
  let result = 0;
  for (let i = 0; i < aList.length; i++) {
    let Mi = M / mList[i];
    let inv = exgcd(Mi, mList[i]);
    if (inv.gcd !== 1) {
      return { success: false, error: `模数 ${mList[i]} 不互质` };
    }
    let x = (inv.x % mList[i] + mList[i]) % mList[i];
    result = (result + aList[i] * Mi * x) % M;
  }
  
  return { success: true, x: result, M: M };
}

// ==================== 费马定理 ====================
export function fermatAccel(a: number, exp: number, mod: number): { result: number, details: string, error?: string } {
  if (mod === 1) return { result: 0, details: '任何数 mod 1 = 0' };
  if (mod <= 0) return { result: 0, details: '', error: '模数必须为正整数' };
  if (a === 0) return { result: 0, details: '0 的任何次方 = 0' };
  
  let base = ((a % mod) + mod) % mod;
  let g = gcd(base, mod);
  let phi = eulerPhi(mod);
  let lines: string[] = [];
  
  lines.push(`📐 计算 ${a}^${exp} mod ${mod}`);
  lines.push('');
  lines.push(`gcd(${base}, ${mod}) = ${g}`);
  
  if (g === 1) {
    lines.push('✅ 互质，使用欧拉定理');
    lines.push(`φ(${mod}) = ${phi}`);
    
    if (isPrime(mod)) {
      lines.push(`💡 ${mod} 是质数，可用费马小定理`);
      lines.push(`  ${base}^(${mod}-1) ≡ 1 (mod ${mod})`);
    }
    
    let newExp = exp % phi;
    lines.push('');
    lines.push(`指数化简：${exp} mod ${phi} = ${newExp}`);
    lines.push(`计算 ${base}^${newExp} mod ${mod}`);
    
    let result = fastPow(base, newExp, mod);
    lines.push(`✅ 结果：${result}`);
    return { result: result, details: lines.join('\n') };
  } else {
    lines.push('⚠️ 不互质，不能使用欧拉定理');
    lines.push('直接使用快速幂计算');
    let result = fastPow(base, exp, mod);
    lines.push(`✅ 结果：${result}`);
    return { result: result, details: lines.join('\n') };
  }
}

// ==================== 不定方程 ====================
export function solveEquation(a: number, b: number, c: number): {
  hasSolution: boolean,
  x0?: number,
  y0?: number,
  gcd?: number,
  a?: number,
  b?: number,
  c?: number,
  message?: string
} {
  if (a === 0 && b === 0) {
    if (c === 0) return { hasSolution: true, message: '方程有无数解' };
    return { hasSolution: false, message: '方程无解' };
  }
  if (a === 0) {
    if (c % b === 0) return { hasSolution: true, x0: 0, y0: c / b, gcd: Math.abs(b), a: a, b: b, c: c };
    return { hasSolution: false, message: '方程无解（b 不能整除 c）' };
  }
  if (b === 0) {
    if (c % a === 0) return { hasSolution: true, x0: c / a, y0: 0, gcd: Math.abs(a), a: a, b: b, c: c };
    return { hasSolution: false, message: '方程无解（a 不能整除 c）' };
  }
  let absA = Math.abs(a), absB = Math.abs(b);
  let result = exgcd(absA, absB);
  let g = result.gcd;
  if (c % g !== 0) {
    return { hasSolution: false, message: `方程无解（${c} 不能被 ${g} 整除）` };
  }
  let x = result.x, y = result.y;
  if (a < 0) x = -x;
  if (b < 0) y = -y;
  return { hasSolution: true, x0: x * (c / g), y0: y * (c / g), gcd: g, a: a, b: b, c: c };
}

// ==================== 表达式求值 ====================
function getPriority(op: string): number {
  switch (op) {
    case '(': return 0;
    case '+': 
    case '-': return 1;
    case '*': 
    case '/': return 2;
    default: return -1;
  }
}

function calc(a: number, b: number, op: string): number {
  switch (op) {
    case '+': return a + b;
    case '-': return a - b;
    case '*': return a * b;
    case '/':
      if (Math.abs(b) < 1e-12) throw new Error('除数不能为零！');
      return a / b;
    default:
      throw new Error(`未知运算符: ${op}`);
  }
}

export function evalExpression(expr: string): number {
  if (!expr || expr.trim().length === 0) throw new Error('表达式为空！');
  
  let numStack: number[] = [];
  let opStack: string[] = [];
  let numBuffer = '';
  let len = expr.length;

  for (let i = 0; i < len; i++) {
    let ch = expr[i];
    if (ch === ' ') continue;

    // 处理负号
    if (ch === '-' && (i === 0 || expr[i-1] === '(' || expr[i-1] === '+' || 
        expr[i-1] === '-' || expr[i-1] === '*' || expr[i-1] === '/')) {
      numBuffer += '-';
      continue;
    }

    if ((ch >= '0' && ch <= '9') || ch === '.') {
      numBuffer += ch;
      continue;
    }

    if (numBuffer.length > 0) {
      numStack.push(parseFloat(numBuffer));
      numBuffer = '';
    }

    if (ch === '(') {
      opStack.push(ch);
    } else if (ch === ')') {
      while (opStack.length > 0 && opStack[opStack.length - 1] !== '(') {
        let op = opStack.pop()!;
        let b = numStack.pop()!;
        let a = numStack.pop()!;
        numStack.push(calc(a, b, op));
      }
      if (opStack.length === 0) throw new Error('括号不匹配！');
      opStack.pop();
    } else if (ch === '+' || ch === '-' || ch === '*' || ch === '/') {
      while (opStack.length > 0 && getPriority(opStack[opStack.length - 1]) >= getPriority(ch)) {
        let op = opStack.pop()!;
        let b = numStack.pop()!;
        let a = numStack.pop()!;
        numStack.push(calc(a, b, op));
      }
      opStack.push(ch);
    } else {
      throw new Error(`非法字符: ${ch}`);
    }
  }

  if (numBuffer.length > 0) {
    numStack.push(parseFloat(numBuffer));
  }

  while (opStack.length > 0) {
    let op = opStack.pop()!;
    let b = numStack.pop()!;
    let a = numStack.pop()!;
    numStack.push(calc(a, b, op));
  }

  if (numStack.length !== 1) throw new Error('表达式不完整！');
  return numStack[0];
}