// entry/src/main/ets/pages/Index.ets
import {
  gcdMultiple, lcmMultiple, isPrime, filterPrimes,
  eulerPhi, getCoprimeNumbers, fastPow, crt,
  fermatAccel, solveEquation, evalExpression
} from '../common/MathEngine';

// Tab 枚举
enum MathTab {
  GCD = 0,
  LCM = 1,
  PRIME = 2,
  PHI = 3,
  MODPOW = 4,
  CRT = 5,
  FERMAT = 6,
  EQUATION = 7,
  CALC = 8
}

@Entry
@Component
struct Index {
  @State currentTab: number = MathTab.GCD;
  @State result: string = '等待计算...';
  @State isError: boolean = false;
  @State status: string = '✅ 就绪';

  // 输入状态
  @State gcdInput: string = '12 18 24';
  @State lcmInput: string = '3 4 5';
  @State primeInput: string = '7 11 13 4';
  @State phiInput: string = '10';
  @State modpowN: string = '3';
  @State modpowM: string = '5';
  @State modpowB: string = '7';
  @State crtA: string = '2,3,2';
  @State crtM: string = '3,5,7';
  @State fermatA: string = '2';
  @State fermatExp: string = '100';
  @State fermatMod: string = '7';
  @State equationInput: string = '3x + 5y = 7';
  @State calcInput: string = '3 + 5 * 2';

  private tabTitles: string[] = [
    'Σ GCD', '∏ LCM', 'ℙ 质数', 'φ 欧拉',
    '^ 模幂', '⊞ CRT', 'ℱ 费马', '≡ 方程', '∫ 计算'
  ];
  private tabIcons: string[] = [
    'Σ', '∏', 'ℙ', 'φ', '^', '⊞', 'ℱ', '≡', '∫'
  ];

  // 计算结果
  setResult(value: string, isErr: boolean = false): void {
    this.result = value;
    this.isError = isErr;
  }

  setStatus(msg: string, isErr: boolean = false): void {
    this.status = (isErr ? '❌ ' : '✅ ') + msg;
  }

  // ========== GCD ==========
  calculateGCD(): void {
    try {
      let nums = this.gcdInput.trim().split(/\s+/).map(Number);
      if (nums.some(isNaN) || nums.length === 0) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      let result = gcdMultiple(nums);
      this.setResult(`最大公约数：${result}`);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== LCM ==========
  calculateLCM(): void {
    try {
      let nums = this.lcmInput.trim().split(/\s+/).map(Number);
      if (nums.some(isNaN) || nums.length === 0) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      let result = lcmMultiple(nums);
      this.setResult(`最小公倍数：${result}`);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== 质数 ==========
  calculatePrime(): void {
    try {
      let nums = this.primeInput.trim().split(/\s+/).map(Number);
      if (nums.some(isNaN) || nums.length === 0) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      if (nums.length === 1) {
        let result = isPrime(nums[0]);
        this.setResult(result ? `✅ ${nums[0]} 是质数` : `❌ ${nums[0]} 不是质数`);
      } else {
        let primes = filterPrimes(nums);
        this.setResult(primes.length === 0 ? '这些数中没有质数 😅' : `质数：${primes.join(', ')} ✅`);
      }
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== 欧拉函数 ==========
  calculatePhi(): void {
    try {
      let n = parseInt(this.phiInput.trim());
      if (isNaN(n) || n <= 0) {
        this.setResult('请输入正整数！', true);
        return;
      }
      let result = eulerPhi(n);
      let coprimes = getCoprimeNumbers(n);
      let detail = `📐 φ(${n}) = ${result}\n\n与 ${n} 互质的数：\n${coprimes.join(', ')}\n\n个数：${coprimes.length}`;
      this.setResult(detail);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== 模幂 ==========
  calculateModPow(): void {
    try {
      let n = parseInt(this.modpowN.trim());
      let m = parseInt(this.modpowM.trim());
      let b = parseInt(this.modpowB.trim());
      if (isNaN(n) || isNaN(m) || isNaN(b)) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      if (b <= 0) { this.setResult('模数必须为正整数！', true); return; }
      if (m < 0) { this.setResult('指数必须为非负整数！', true); return; }
      
      let result = fastPow(n, m, b);
      let detail = `📐 ${n}^${m} ≡ x (mod ${b})\n\n`;
      detail += `第1步：底数取模\n  ${n} mod ${b} = ${(n % b + b) % b}\n\n`;
      detail += `第2步：快速幂计算\n  ${n}^${m} ≡ ${result} (mod ${b})`;
      this.setResult(detail);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== CRT ==========
  calculateCRT(): void {
    try {
      let aList = this.crtA.split(',').map(s => parseInt(s.trim()));
      let mList = this.crtM.split(',').map(s => parseInt(s.trim()));
      
      if (aList.some(isNaN) || mList.some(isNaN)) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      if (aList.length !== mList.length) {
        this.setResult('余数和模数的数量必须相同！', true);
        return;
      }
      
      let result = crt(aList, mList);
      if (!result.success) {
        this.setResult(`错误：${result.error}`, true);
        this.setStatus('计算失败', true);
        return;
      }
      
      let lines: string[] = ['📐 求解同余方程组：'];
      for (let i = 0; i < aList.length; i++) {
        lines.push(`  x ≡ ${aList[i]} (mod ${mList[i]})`);
      }
      lines.push('');
      lines.push(`✅ 通解：x ≡ ${result.x} (mod ${result.M})`);
      lines.push(`💡 最小的正整数解：${result.x === 0 ? result.M : result.x}`);
      
      this.setResult(lines.join('\n'));
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== 费马定理 ==========
  calculateFermat(): void {
    try {
      let a = parseInt(this.fermatA.trim());
      let exp = parseInt(this.fermatExp.trim());
      let mod = parseInt(this.fermatMod.trim());
      
      if (isNaN(a) || isNaN(exp) || isNaN(mod)) {
        this.setResult('请输入有效的整数！', true);
        return;
      }
      if (mod <= 0) { this.setResult('模数必须为正整数！', true); return; }
      if (exp < 0) { this.setResult('指数必须为非负整数！', true); return; }
      
      let result = fermatAccel(a, exp, mod);
      if (result.error) {
        this.setResult(`错误：${result.error}`, true);
        this.setStatus('计算失败', true);
        return;
      }
      this.setResult(result.details);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // ========== 不定方程 ==========
  calculateEquation(): void {
    try {
      let input = this.equationInput.trim();
      let s = input.replace(/\s/g, '');
      let eqPos = s.indexOf('=');
      if (eqPos === -1) throw new Error('未找到 "=" 符号');
      
      let left = s.substring(0, eqPos);
      let right = s.substring(eqPos + 1);
      let c = parseInt(right);
      if (isNaN(c)) throw new Error('等号右侧不是整数');
      
      let terms: string[] = [];
      let current = '';
      for (let i = 0; i < left.length; i++) {
        let ch = left[i];
        if ((ch === '+' || ch === '-') && i > 0) {
          terms.push(current);
          current = ch;
        } else {
          current += ch;
        }
      }
      if (current) terms.push(current);
      if (terms.length === 0) terms = [left];
      
      let a = 0, b = 0;
      for (let term of terms) {
        let xPos = term.indexOf('x');
        let yPos = term.indexOf('y');
        if (xPos !== -1) {
          let coefStr = term.substring(0, xPos);
          if (coefStr === '' || coefStr === '+') a = 1;
          else if (coefStr === '-') a = -1;
          else a = parseInt(coefStr);
          if (isNaN(a)) throw new Error('x 的系数无效');
        } else if (yPos !== -1) {
          let coefStr = term.substring(0, yPos);
          if (coefStr === '' || coefStr === '+') b = 1;
          else if (coefStr === '-') b = -1;
          else b = parseInt(coefStr);
          if (isNaN(b)) throw new Error('y 的系数无效');
        }
      }
      
      let result = solveEquation(a, b, c);
      if (!result.hasSolution) {
        this.setResult(`❌ ${result.message}`, true);
        this.setStatus('求解失败', true);
        return;
      }
      
      if (result.message) {
        this.setResult(result.message);
        this.setStatus('求解完成');
        return;
      }
      
      let lines: string[] = [];
      lines.push(`📐 方程：${a}x + ${b}y = ${c}`);
      lines.push(`🔢 gcd(${a}, ${b}) = ${result.gcd}`);
      lines.push('');
      lines.push(`📌 特解：\n  x₀ = ${result.x0}\n  y₀ = ${result.y0}`);
      lines.push('');
      let t1 = result.b! / result.gcd!;
      let t2 = result.a! / result.gcd!;
      if (t1 < 0) { t1 = -t1; t2 = -t2; }
      lines.push(`📝 通解：\n  x = ${result.x0} + ${t1}t\n  y = ${result.y0} - ${t2}t\n  其中 t 为任意整数`);
      
      this.setResult(lines.join('\n'));
      this.setStatus('求解完成');
    } catch (e) {
      this.setResult(`解析错误：${e}`, true);
      this.setStatus('解析失败', true);
    }
  }

  // ========== 计算器 ==========
  calculateCalc(): void {
    try {
      let result = evalExpression(this.calcInput.trim());
      let display = Number.isInteger(result) ? result.toString() : result.toFixed(4);
      this.setResult(`= ${display}`);
      this.setStatus('计算完成');
    } catch (e) {
      this.setResult(`错误：${e}`, true);
      this.setStatus('计算失败', true);
    }
  }

  // 渲染对应 Tab 的内容
  @Builder
  buildTabContent(index: number) {
    switch (index) {
      case MathTab.GCD:
        this.GCDContent();
        break;
      case MathTab.LCM:
        this.LCMContent();
        break;
      case MathTab.PRIME:
        this.PrimeContent();
        break;
      case MathTab.PHI:
        this.PhiContent();
        break;
      case MathTab.MODPOW:
        this.ModPowContent();
        break;
      case MathTab.CRT:
        this.CRTContent();
        break;
      case MathTab.FERMAT:
        this.FermatContent();
        break;
      case MathTab.EQUATION:
        this.EquationContent();
        break;
      case MathTab.CALC:
        this.CalcContent();
        break;
      default:
        Text('未知功能');
    }
  }

  // ========== Tab 内容构建 ==========

  @Builder
  GCDContent() {
    Column() {
      Text('请输入整数（用空格分隔）')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      TextInput({ text: this.gcdInput, placeholder: '例如：12 18 24' })
        .width('100%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .border({ width: 0 })
        .onChange((value: string) => { this.gcdInput = value; })
      
      Button('计算最大公约数')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#667eea')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateGCD())
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  LCMContent() {
    Column() {
      Text('请输入整数（用空格分隔）')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      TextInput({ text: this.lcmInput, placeholder: '例如：3 4 5' })
        .width('100%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .border({ width: 0 })
        .onChange((value: string) => { this.lcmInput = value; })
      
      Button('计算最小公倍数')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#f093fb')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateLCM())
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  PrimeContent() {
    Column() {
      Text('请输入整数（用空格分隔）')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      TextInput({ text: this.primeInput, placeholder: '例如：7 11 13 4' })
        .width('100%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .border({ width: 0 })
        .onChange((value: string) => { this.primeInput = value; })
      
      Button('判断质数')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#4facfe')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculatePrime())
      
      Text('💡 单个数字：判断是否为质数\n多个数字：筛选出其中的质数')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  PhiContent() {
    Column() {
      Text('计算欧拉函数 φ(n)')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      Row() {
        TextInput({ text: this.phiInput, placeholder: '请输入 n' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.phiInput = value; })
        
        Button('计算')
          .height(44)
          .padding({ left: 20, right: 20 })
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#43e97b')
          .borderRadius(12)
          .margin({ left: 8 })
          .onClick(() => this.calculatePhi())
      }
      .width('100%')
      
      Text('💡 φ(n) = 1 到 n 中与 n 互质的数的个数\n示例：φ(10) = 4（1, 3, 7, 9）')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  ModPowContent() {
    Column() {
      Text('计算 n^m ≡ x (mod b)')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      Row() {
        TextInput({ text: this.modpowN, placeholder: '底数 n' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.modpowN = value; })
        
        Text('^')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8, right: 8 })
        
        TextInput({ text: this.modpowM, placeholder: '指数 m' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.modpowM = value; })
        
        Text('mod')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8, right: 8 })
        
        TextInput({ text: this.modpowB, placeholder: '模数 b' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.modpowB = value; })
      }
      .width('100%')
      
      Button('计算模幂')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#fa709a')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateModPow())
      
      Text('💡 求 n 的 m 次方除以 b 的余数\n示例：3^5 mod 7 = 5')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  CRTContent() {
    Column() {
      Text('中国剩余定理 (CRT)')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      Row() {
        TextInput({ text: this.crtA, placeholder: 'a (余数)' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.crtA = value; })
        
        Text('mod')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8, right: 8 })
        
        TextInput({ text: this.crtM, placeholder: 'm (模数)' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.crtM = value; })
      }
      .width('100%')
      
      Text('格式：用逗号分隔，例如 a: 2,3,2  m: 3,5,7')
        .fontSize(12)
        .fontColor('#888')
        .width('100%')
        .margin({ top: 4, bottom: 8 })
      
      Button('求解 CRT')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#a18cd1')
        .borderRadius(12)
        .onClick(() => this.calculateCRT())
      
      Text('💡 求解同余方程组：x ≡ a₁ (mod m₁), x ≡ a₂ (mod m₂), ...\n示例：x ≡ 2 (mod 3), x ≡ 3 (mod 5), x ≡ 2 (mod 7) → x = 23')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  FermatContent() {
    Column() {
      Text('费马小定理 / 欧拉定理')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      Row() {
        TextInput({ text: this.fermatA, placeholder: '底数 a' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.fermatA = value; })
        
        Text('^')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8, right: 8 })
        
        TextInput({ text: this.fermatExp, placeholder: '指数' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.fermatExp = value; })
        
        Text('mod')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 8, right: 8 })
        
        TextInput({ text: this.fermatMod, placeholder: '模数 p' })
          .layoutWeight(1)
          .height(44)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .border({ width: 0 })
          .onChange((value: string) => { this.fermatMod = value; })
      }
      .width('100%')
      
      Button('计算（加速）')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#ffecd2')
        .fontColor('#7a3a0a')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateFermat())
      
      Text('💡 利用费马小定理/欧拉定理加速计算 a^b mod p\n• 若 p 为质数：a^(p-1) ≡ 1 (mod p)\n• 一般情况：a^φ(n) ≡ 1 (mod n)（当 gcd(a,n)=1）')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  EquationContent() {
    Column() {
      Text('请输入二元一次不定方程：')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      TextInput({ text: this.equationInput, placeholder: '例如：3x + 5y = 7' })
        .width('100%')
        .height(44)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .border({ width: 0 })
        .onChange((value: string) => { this.equationInput = value; })
      
      Button('求解不定方程')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#fbc2eb')
        .fontColor('#4a2a6a')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateEquation())
      
      Text('💡 支持格式：ax + by = c\n示例：3x + 5y = 7, 2x - 4y = 6')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  @Builder
  CalcContent() {
    Column() {
      Text('请输入数学表达式：')
        .fontSize(14)
        .fontColor('#666')
        .width('100%')
        .margin({ bottom: 8 })
      
      TextArea({ text: this.calcInput, placeholder: '例如：3 + 5 * 2' })
        .width('100%')
        .height(80)
        .backgroundColor(Color.White)
        .borderRadius(12)
        .border({ width: 0 })
        .fontSize(16)
        .onChange((value: string) => { this.calcInput = value; })
      
      Button('计算')
        .width('100%')
        .height(48)
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#fcb69f')
        .fontColor('#7a3a0a')
        .borderRadius(12)
        .margin({ top: 12 })
        .onClick(() => this.calculateCalc())
      
      Text('💡 支持：+ - * / ( ) 小数 负数')
        .fontSize(13)
        .fontColor('#856404')
        .width('100%')
        .padding(12)
        .backgroundColor('#fff3cd')
        .borderRadius(10)
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('rgba(255,255,255,0.6)')
    .borderRadius(20)
    .backdropBlur(20)
  }

  build() {
    Column() {
      // 标题
      Text('🧮 多功能数学工具')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333')
        .width('100%')
        .textAlign(TextAlign.Center)
        .margin({ bottom: 20 })

      // Tab 切换 - 液态玻璃风格
      Tabs({ index: this.currentTab }) {
        ForEach(this.tabTitles, (title: string, index: number) => {
          TabContent() {
            this.buildTabContent(index)
          }
          .tabBar(this.TabBarBuilder(index, title))
        })
      }
      .width('100%')
      .height(420)
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .backgroundColor('transparent')
      .onChange((index: number) => {
        this.currentTab = index;
        this.setStatus('就绪');
      })

      // 结果区域 - 液态玻璃
      Column() {
        Text('计算结果')
          .fontSize(14)
          .fontColor('#888')
          .width('100%')
        
        Text(this.result)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isError ? '#ff6b6b' : '#333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .padding({ top: 6 })
      }
      .width('100%')
      .padding(16)
      .margin({ top: 16 })
      .backgroundColor('rgba(255,255,255,0.6)')
      .borderRadius(16)
      .backdropBlur(20)
      .alignItems(HorizontalAlign.Start)
      .minHeight(80)

      // 状态栏
      Text(this.status)
        .fontSize(14)
        .fontColor(this.status.includes('❌') ? '#c62828' : '#2e7d32')
        .width('100%')
        .padding(10)
        .margin({ top: 12 })
        .backgroundColor(this.status.includes('❌') ? 'rgba(255,235,238,0.8)' : 'rgba(232,245,233,0.8)')
        .borderRadius(10)
        .textAlign(TextAlign.Center)
        .backdropBlur(10)
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundImage($r('app.media.background_gradient'))
    .backgroundImageSize(ImageSize.Cover)
  }

  // TabBar 构建器 - 液态玻璃风格
  @Builder
  TabBarBuilder(index: number, title: string) {
    Column() {
      Text(this.tabIcons[index])
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      Text(title)
        .fontSize(11)
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .borderRadius(12)
    .backgroundColor(this.currentTab === index ? 'rgba(255,255,255,0.3)' : 'transparent')
    .backdropBlur(this.currentTab === index ? 20 : 0)
    .border({
      width: this.currentTab === index ? 1 : 0,
      color: 'rgba(255,255,255,0.2)'
    })
  }
}