//
//  ViewController.swift
//  PI5
//
//  Created by Gustavo Garcia Leite on 10/04/19.
//  Copyright © 2019 Gustavo Garcia Leite. All rights reserved.
//
import Foundation
import UIKit

class SimuladorViewController: UIViewController {
    
    @IBOutlet weak var btnSimular: UIButton!
    @IBOutlet weak var lblTempo: UILabel!
    @IBOutlet weak var cAView: UIView!
    @IBOutlet weak var aView: UIView!
    @IBOutlet weak var cAImageView: UIImageView!
    @IBOutlet weak var lblCA: UILabel!
    @IBOutlet weak var agua: UIImageView!
    @IBOutlet weak var imgNuvemPAzul: UIImageView!
    @IBOutlet weak var imgNuvemPCinza: UIImageView!
    @IBOutlet weak var imgNuvemGCinza: UIImageView!
    @IBOutlet weak var imgNuvemGAzul: UIImageView!
    @IBOutlet weak var imgCeuDia: UIImageView!
    @IBOutlet weak var imgCeuNoite: UIImageView!
    @IBOutlet weak var imgSol: UIImageView!
    @IBOutlet weak var imgLua: UIImageView!
    @IBOutlet weak var lblCompartimentoA: UILabel!
    @IBOutlet weak var btnAdicionar: UIButton!
    @IBOutlet weak var btnRemover: UIButton!
    @IBOutlet weak var txtQtdCompA: UITextField!
    @IBOutlet weak var txtTaxaA: UITextField!
    @IBOutlet weak var lblDias: UILabel!
    
    @IBOutlet weak var segmentedVelocity: UISegmentedControl!
    
    @IBOutlet weak var sliderDias: UISlider!
    
    @IBOutlet weak var btnReset: UIButton!
    
    var timer: Timer = Timer()
    var timerInterval: TimeInterval = 1.0
    var segundos = 0
    var isAnimating = false
    var valoresCA = [Double]()
    var valoresCB = [Double]()
    var valoresCC = [Double]()
    var quant = [Double]()
    
    let alfabeto: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I"]
    var matrizValores: [[Double]] = [[Double]]()
    var diferencas: [Double] = []
    var copiaCompartimentos: [Double] = []
    
    
    var arrayLabelsValores = [UILabel]()
    var arrayLabels = [UILabel]()
    var arrayViews = [UIView]()
    var arrayCViews = [UIView]()
    var arrayImageViews = [UIImageView]()
    var matrizTxtTaxa = [[UITextField]]()
    var arrayTxtQtd = [UITextField]()
    
    
    var isSimulating = false
    var k = 20
    
    var velocidade = 1
    var compartimentos: [Double] = [1000, 0, 0]
    var qtdDias = 1.0
    var h = 0.001
    var taxas: [[Double]] = [ [-0.1, 0.1, 0.0],
                              [0.0, -0.05, 0.05],
                              [0.01, 0.0, -0.01]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        didLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @IBAction func reset(_ sender: UIButton) {
        
        for i in 0...compartimentos.count - 1 {
            self.arrayCViews[i].layer.removeAllAnimations()
        }
        
        timer.invalidate()
        isSimulating = false
        isAnimating = false
        segundos = 0
        habilitarBtns()
        self.imgLua.layer.removeAllAnimations()
        self.imgCeuNoite.layer.removeAllAnimations()
        setup()
        
        
    }
    
    
    @IBAction func sliderDias(_ sender: UISlider) {
        guard !isSimulating else { return }
        lblDias.text = "\(Int(round(Double(sender.value) * 1)/1)) dias"
        self.qtdDias = round(Double(sender.value) * 1)/1
    }
    
    func didLoad() {
        animacoes()
        btnReset.layer.cornerRadius = 5
        btnSimular.layer.cornerRadius = 5
        btnAdicionar.layer.cornerRadius = self.btnAdicionar.frame.width/2
        btnRemover.layer.cornerRadius = self.btnRemover.frame.width/2
        
        configuraTxtFieldIniciais(txtField: txtQtdCompA)
        configuraTxtFieldIniciais(txtField: txtTaxaA)
        arrayTxtQtd.append(txtQtdCompA)
        var novoArrayTxtField = [UITextField]()
        novoArrayTxtField.append(txtTaxaA)
        matrizTxtTaxa.append(novoArrayTxtField)
        arrayLabels.append(lblCompartimentoA)
        arrayViews.append(aView)
        arrayCViews.append(cAView)
        arrayImageViews.append(cAImageView)
        arrayLabelsValores.append(lblCA)
    }
    
    
    @IBAction func removerCompartimento(_ sender: UIButton) {
        
        guard !isSimulating else { return }
        
        guard arrayViews.count > 1 else { return }
        
        arrayLabelsValores.last?.removeFromSuperview()
        arrayLabelsValores.removeLast()
        arrayViews.last?.removeFromSuperview()
        arrayViews.removeLast()
        arrayCViews.last?.removeFromSuperview()
        arrayCViews.removeLast()
        arrayImageViews.last?.removeFromSuperview()
        arrayImageViews.removeLast()
        arrayLabels.last?.removeFromSuperview()
        arrayLabels.removeLast()
        arrayTxtQtd.last?.removeFromSuperview()
        arrayTxtQtd.removeLast()
        
        for i in 0...matrizTxtTaxa.last!.count - 1 {
            matrizTxtTaxa.last![i].removeFromSuperview()
        }
        
        matrizTxtTaxa.removeLast()
        
        for j in 0...matrizTxtTaxa.count - 1 {
            matrizTxtTaxa[j].last?.removeFromSuperview()
            matrizTxtTaxa[j].removeLast()
        }
    }
    
    
    @IBAction func adicionarCompartimento(_ sender: UIButton) {
        
        guard !isSimulating else { return }
        
        let novoCView = UIView(frame: CGRect(x: arrayCViews.last!.frame.origin.x + 190, y: arrayViews.first!.frame.origin.y, width: 144, height: 96))
        novoCView.backgroundColor = arrayCViews.last?.backgroundColor
        
        let novoView = UIView(frame: CGRect(x: arrayViews.last!.frame.origin.x + 190, y: arrayCViews.first!.frame.origin.y, width: 144, height: 96))
        novoView.backgroundColor = arrayViews.last?.backgroundColor
        
        let novoImageView = UIImageView(frame: CGRect(x: arrayImageViews.last!.frame.origin.x + 190, y: arrayImageViews.last!.frame.origin.y, width: 158, height: 108))
        novoImageView.image = arrayImageViews.last?.image
        
        let novoLabelCompartimento = UILabel(frame: CGRect(x: arrayLabels.last!.frame.origin.x + 190, y: arrayLabels.last!.frame.origin.y, width: 144, height: 16))
        novoLabelCompartimento.textColor = arrayLabels.last?.textColor
        novoLabelCompartimento.font = arrayLabels.last?.font
        novoLabelCompartimento.text = "Compartimento \(alfabeto[arrayLabels.count])"
        novoLabelCompartimento.textAlignment = NSTextAlignment.center
        
        let novoLabelValor = UILabel(frame: CGRect(x: arrayLabelsValores.last!.frame.origin.x + 190, y: arrayLabelsValores.last!.frame.origin.y, width: 131, height: 49))
        novoLabelValor.font = arrayLabelsValores.last?.font
        novoLabelValor.textAlignment = NSTextAlignment.center
        novoLabelValor.textColor = arrayLabelsValores.last?.textColor
        novoLabelValor.text = "C\(alfabeto[arrayLabelsValores.count])"
        
        
        for i in 0...matrizTxtTaxa.count - 1 {
            let txt = UITextField(frame: CGRect(x: matrizTxtTaxa[i].last!.frame.origin.x + 190, y: matrizTxtTaxa[i].last!.frame.origin.y, width: 144, height: 30))
            configuraTxtField(txtField: txt)
            txt.placeholder = "Taxa \(alfabeto[i])-\(alfabeto[matrizTxtTaxa[i].count])"
            matrizTxtTaxa[i].append(txt)
            self.view.addSubview(txt)
        }
        
        matrizTxtTaxa.append([])
        
        for i in 0...matrizTxtTaxa.count - 1 {
            if i == 0 {
                let txt = UITextField(frame: CGRect(x: matrizTxtTaxa[matrizTxtTaxa.count-2][0].frame.origin.x, y: matrizTxtTaxa[matrizTxtTaxa.count-2][0].frame.origin.y + 34, width: 144, height: 30))
                configuraTxtField(txtField: txt)
                txt.placeholder = "Taxa \(alfabeto[i])-\(alfabeto[matrizTxtTaxa.first!.count - 1])"
                matrizTxtTaxa[matrizTxtTaxa.count - 1].append(txt)
                self.view.addSubview(txt)
            } else {
                let txt = UITextField(frame: CGRect(x: matrizTxtTaxa[matrizTxtTaxa.count - 1].last!.frame.origin.x + 190, y: matrizTxtTaxa[matrizTxtTaxa.count - 1].last!.frame.origin.y, width: 144, height: 30))
                configuraTxtField(txtField: txt)
                txt.placeholder = "Taxa \(alfabeto[i])-\(alfabeto[matrizTxtTaxa.first!.count - 1])"
                matrizTxtTaxa[matrizTxtTaxa.count - 1].append(txt)
                self.view.addSubview(txt)
            }
        }
        
        let novoTxtFieldQtd = UITextField(frame: CGRect(x: arrayTxtQtd.last!.frame.origin.x + 190, y: arrayTxtQtd.last!.frame.origin.y, width: 144, height: 30))
        configuraTxtField(txtField: novoTxtFieldQtd)
        novoTxtFieldQtd.placeholder = "Qtd. Compartimento \(alfabeto[arrayTxtQtd.count])"
        
        arrayViews.append(novoView)
        arrayCViews.append(novoCView)
        arrayImageViews.append(novoImageView)
        arrayLabels.append(novoLabelCompartimento)
        arrayTxtQtd.append(novoTxtFieldQtd)
        arrayLabelsValores.append(novoLabelValor)
        
        self.view.addSubview(novoView)
        self.view.addSubview(novoCView)
        self.view.addSubview(novoImageView)
        self.view.addSubview(novoLabelCompartimento)
        self.view.addSubview(novoTxtFieldQtd)
        self.view.addSubview(novoLabelValor)
        
    }
    
    func configuraTxtField(txtField: UITextField) {
        txtField.textColor = arrayTxtQtd.last?.textColor
        txtField.backgroundColor = arrayTxtQtd.last?.backgroundColor
        txtField.font = arrayTxtQtd.last?.font
        txtField.borderStyle = UITextField.BorderStyle.roundedRect
        txtField.autocorrectionType = UITextAutocorrectionType.no
        txtField.keyboardType = UIKeyboardType.decimalPad
        txtField.returnKeyType = UIReturnKeyType.done
        txtField.clearButtonMode = UITextField.ViewMode.whileEditing
        txtField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        txtField.textAlignment = NSTextAlignment.center
    }
    
    func configuraTxtFieldIniciais(txtField: UITextField) {
        txtField.borderStyle = UITextField.BorderStyle.roundedRect
        txtField.autocorrectionType = UITextAutocorrectionType.no
        txtField.keyboardType = UIKeyboardType.decimalPad
        txtField.returnKeyType = UIReturnKeyType.done
        txtField.clearButtonMode = UITextField.ViewMode.whileEditing
        txtField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        txtField.textAlignment = NSTextAlignment.center
    }
    
    func formataArrayTaxas() {
        taxas = [[Double]]()
        compartimentos = [Double]()
        
        for i in 0...matrizTxtTaxa.count - 1 {
            taxas.append([])
            for j in 0...matrizTxtTaxa[i].count - 1 {
                taxas[i].append((matrizTxtTaxa[i][j].text! as NSString).doubleValue)
            }
        }
        
        for txt in arrayTxtQtd {
            compartimentos.append((txt.text! as NSString).doubleValue)
        }
        
        for j in 0...arrayLabelsValores.count - 1 {
            arrayLabelsValores[j].text = "\(compartimentos[j])"
        }
    }
    
    func fazFormula(arrayComp: [Double], qtd: Double, arrayK: [Double]) -> [Double] {
        var matrizSomada = [Double]()
        for linha in 0...arrayComp.count - 1 {
            var soma = 0.0
            for coluna in 0...taxas.count - 1 {
                soma += (arrayComp[coluna] + (qtd * arrayK[coluna])) * taxas[coluna][linha]
            }
            matrizSomada.append(soma)
        }
        return matrizSomada
    }
    
    func fazFormulaK1(arrayComp: [Double]) -> [Double] {
        var matrizSomada = [Double]()
        for linha in 0...arrayComp.count - 1 {
            var soma = 0.0
            for coluna in 0...taxas.count - 1 {
                soma += arrayComp[coluna] * taxas[coluna][linha]
            }
            matrizSomada.append(soma)
        }
        return matrizSomada
    }
    
    func calcula() {
        var j: Double = 0.0
        copiaCompartimentos = compartimentos
        var copyArray: [Double] = compartimentos
        print(copyArray)
        while j < qtdDias {
            let k1 = fazFormulaK1(arrayComp: copyArray)
            let k2 = fazFormula(arrayComp: copyArray, qtd: h/2, arrayK: k1)
            let k3 = fazFormula(arrayComp: copyArray, qtd: h/2, arrayK: k2)
            let k4 = fazFormula(arrayComp: copyArray, qtd: h, arrayK: k3)
            copyArray = determinaNovoValor(arrayComp: copyArray, h: h, k1: k1, k2: k2, k3: k3, k4: k4)
            j += h
            let value = 100000000000.0
            if round(j * 1)/1 == round(j * value)/value {
                var possui = false
                for array in matrizValores {
                    if copyArray.first == array.first {
                        possui = true
                    }
                }
                if !possui {
                    matrizValores.append(copyArray)
                    print("append: ", copyArray)
                }
                
            }
            
            retornaSoma(array: copyArray)
        }
        
        print("Final: \(copyArray)")
        print("Qtd valores: \(matrizValores.count)")
        compartimentos = copyArray
    }
    
    func determinaNovoValor(arrayComp: [Double], h: Double, k1: [Double], k2: [Double], k3: [Double], k4: [Double]) -> [Double]{
        var copyArray: [Double] = arrayComp
        for i in 0...copyArray.count - 1 {
            copyArray[i] = copyArray[i] + (h/6) * (k1[i] + (2 * k2[i]) + (2 * k3[i]) + k4[i])
        }
        return copyArray
    }
    
    func retornaSoma(array: [Double]) {
        var soma = 0.0
        for item in array {
            soma += item
        }
    }
    
    func determinaDiferenca() {
        
        diferencas = []
        
        for i in 0...compartimentos.count - 1 {
            let d = copiaCompartimentos[i] - compartimentos[i]
            diferencas.append(d)
        }
        
        print(diferencas)
    }
    
    func animacoes() {
        
        UIView.animate(withDuration: 2, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            
            
            self.imgNuvemPAzul.frame.origin.x += 20
            self.imgNuvemPCinza.frame.origin.x -= 20
            self.agua.frame.origin.y -= 20
            
        }, completion: nil)
        
        UIView.animate(withDuration: 2, delay: 0.25, options: [.repeat, .autoreverse], animations: {
            
            self.imgNuvemGAzul.frame.origin.x += CGFloat(self.k)
            self.imgNuvemGCinza.frame.origin.x += CGFloat(self.k)
            
        }, completion:  nil)
    }
    
    func verificaTxtField() -> Bool {
        
        for txt in arrayTxtQtd {
            if txt.text == "" {
                return false
            }
        }
        
        for i in 0...matrizTxtTaxa.count - 1 {
            for j in 0...matrizTxtTaxa.count - 1 {
                if matrizTxtTaxa[i][j].text == ""{
                    return false
                }
            }
        }
        
        return true
    }
    
    @IBAction func simular(_ sender: UIButton) {
        guard !isSimulating else { return }
        guard verificaTxtField() else { return }
        
        desabilitarBtns()
        setup()
        formataArrayTaxas()
        calcula()
        determinaDiferenca()
        anima()
        startTimer()
        isSimulating = true
    }
    
    
    
    func habilitarBtns() {

        sliderDias.alpha = 1
        sliderDias.isUserInteractionEnabled = true
        btnRemover.alpha = 1
        btnRemover.isUserInteractionEnabled = true
        btnSimular.alpha = 1
        btnSimular.isUserInteractionEnabled = true
        btnAdicionar.alpha = 1
        btnAdicionar.isUserInteractionEnabled = true
        segmentedVelocity.alpha = 1
        segmentedVelocity.isUserInteractionEnabled = true
    }
    
    func desabilitarBtns() {

        sliderDias.alpha = 0.6
        sliderDias.isUserInteractionEnabled = false
        btnRemover.alpha = 0.6
        btnRemover.isUserInteractionEnabled = false
        btnSimular.alpha = 0.6
        btnSimular.isUserInteractionEnabled = false
        btnAdicionar.alpha = 0.6
        btnAdicionar.isUserInteractionEnabled = false
        segmentedVelocity.alpha = 0.6
        segmentedVelocity.isUserInteractionEnabled = false
    }
    
    func atribuirValores() {
        let value: Double = 10000
        
        for i in 0...compartimentos.count - 1 {
            arrayLabelsValores[i].text = "\(round(compartimentos[i] * value)/value)"
        }
    }
    
    func regraDeTres(cA: Double, cC: Double, index: Int) -> Double {
        let diferenca = (Double(self.arrayViews[index].frame.height) * cC)/cA
        return diferenca
    }
    func regraDeTres1(cA: Double, cC: Double, index: Int) -> Double {
        let diferenca = (Double(self.arrayCViews[index].frame.height) * cC)/cA
        return diferenca
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: timerInterval/Double(velocidade), target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
    }
    
    @objc func update() {
        
        if segundos < Int(qtdDias) {
            if !isAnimating {
                self.isAnimating = true
                UIView.animate(withDuration: timerInterval/Double(velocidade), delay: 0.0, options: [.curveLinear, .autoreverse], animations: {
                    self.imgCeuNoite.alpha = 0
                    self.imgLua.alpha = 0
                }, completion:{(finished: Bool) in
                    if finished {
                        self.imgCeuNoite.alpha = 1
                        self.imgLua.alpha = 1
                        self.isAnimating = false
                        self.segundos += 1
                    }
                })
                
                for j in 0...matrizValores[segundos].count - 1 {
                    arrayLabelsValores[j].text = "\(round(matrizValores[segundos][j] * 1000000)/1000000)"
                }
                lblTempo.text = "Dia \(segundos + 1)"
            }
        } else {
            timer.invalidate()
            isSimulating = false
            isAnimating = false
            segundos = 0
            habilitarBtns()
        }
    }
    
    func anima() {
        for i in 0...compartimentos.count - 1 {
            UIView.animate(withDuration:(qtdDias * 3)/Double(velocidade), animations: {
                if i == 0 {
                    print("\(i) ", CGFloat(self.regraDeTres(cA: 1000.0, cC: -1 * self.diferencas[i], index: i)))
                    self.arrayCViews[i].frame.size.height += CGFloat(self.regraDeTres(cA: self.copiaCompartimentos[i], cC: self.diferencas[i], index: i))
                }
                else {
                    print("\(i) ", CGFloat(self.regraDeTres1(cA: 1000.0, cC: -1 * self.diferencas[i], index: i)))
                    self.arrayCViews[i].frame.size.height -= CGFloat(self.regraDeTres1(cA: self.copiaCompartimentos.first! + self.copiaCompartimentos[i], cC: -1 * self.diferencas[i], index: i))
                }
            })
        }
    }
    
    func setup() {
        for i in 0...arrayCViews.count - 1 {
            if i == 0 {
                arrayLabelsValores.first?.text = "CA"
                arrayViews.first!.frame = CGRect(x: arrayViews.first!.frame.origin.x, y: 373, width: 144, height: 96)
                arrayCViews.first!.frame = CGRect(x: arrayCViews.first!.frame.origin.x, y: 373, width: 144, height: 1)
            } else {
                arrayLabelsValores[i].text = "C\(alfabeto[i])"
                arrayCViews[i].frame = CGRect(x: arrayCViews[i].frame.origin.x, y: arrayViews.first!.frame.origin.y, width: 144, height: 96)
                arrayViews[i].frame = CGRect(x: arrayCViews[i].frame.origin.x, y: arrayCViews.first!.frame.origin.y, width: 144, height: 96)
            }
        }
        lblTempo.isHidden = false
        lblTempo.text = "Dia \(1)"
        self.matrizValores = []
        self.imgCeuNoite.alpha = 1
        self.imgLua.alpha = 1
    }
    
    @IBAction func mudaVelocidade(_ sender: UISegmentedControl) {
        guard !isSimulating else { return }
        switch sender.selectedSegmentIndex {
        case 0:
            velocidade = 1
        case 1:
            velocidade = 10
        case 2:
            velocidade = 50
        default:
            break
        }
    }
}
