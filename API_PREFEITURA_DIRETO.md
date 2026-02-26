# 🏛️ INTEGRAÇÃO DIRETA COM API DA PREFEITURA

## 🎯 RESPOSTA DIRETA

**SIM, você pode criar sua própria integração diretamente com a API da prefeitura!**

Você **NÃO precisa** do NFE.io. É totalmente possível (e legal) integrar diretamente.

---

## 📊 COMPARAÇÃO: NFE.io vs API Direta

| Aspecto | NFE.io | API Direta Prefeitura |
|---------|--------|----------------------|
| **Custo Mensal** | 💰 R$ 20-200/mês | 💚 **GRÁTIS** (maioria) |
| **Complexidade** | ⭐ Baixa | ⭐⭐⭐ Alta |
| **Tempo Implementação** | ⚡ 2-3 dias | ⏰ 1-2 semanas |
| **Cidades Cobertas** | ✅ 5.000+ | ⚠️ Apenas 1 |
| **API Unificada** | ✅ Sim | ❌ Cada cidade diferente |
| **Suporte Técnico** | ✅ Incluído | ❌ Você sozinho |
| **Certificado Digital** | ✅ Precisa | ✅ Precisa |
| **Homologação** | ✅ Facilitada | ⚠️ Manual |
| **Documentação** | ✅ Excelente | ⚠️ Varia |

---

## 💡 QUANDO USAR CADA OPÇÃO

### **Use NFE.io se:**
- ✅ Atua em **múltiplas cidades**
- ✅ Quer **implementar rápido** (2-3 dias)
- ✅ Não tem experiência com APIs fiscais
- ✅ Valoriza **suporte técnico**
- ✅ Quer **evitar dor de cabeça**
- ✅ Tem **budget** (R$ 20-200/mês)

### **Use API Direta se:**
- ✅ Atua em **apenas 1 cidade**
- ✅ Tem **conhecimento técnico avançado**
- ✅ Quer **economia** (grátis vs R$ 20-200/mês)
- ✅ Não se importa com **complexidade**
- ✅ Tem **tempo** para implementar (1-2 semanas)
- ✅ Quer **controle total**

---

## 🌐 COMO FUNCIONA A API DIRETA

### **Conceito Geral:**

Cada prefeitura tem seu próprio sistema de NFS-e, mas o fluxo geral é similar:

```
Seu Sistema
    ↓
1. Gera XML conforme padrão da prefeitura
    ↓
2. Assina XML com Certificado Digital
    ↓
3. Envia via SOAP/REST para API da prefeitura
    ↓
4. Prefeitura valida e retorna número oficial
    ↓
5. Você salva e gera PDF com dados oficiais
```

---

## 🏙️ PRINCIPAIS PREFEITURAS E SUAS APIS

### **1. São Paulo (SP)** 🏢

**Sistema:** NFe-SP (ISS Online)  
**Site:** https://nfe.prefeitura.sp.gov.br  
**Protocolo:** SOAP (Web Service)  
**Padrão:** ABRASF 2.03  
**Certificado:** A1 ou A3

**Complexidade:** ⭐⭐⭐⭐ Alta

**Documentação:**
- Manual Técnico: https://nfe.prefeitura.sp.gov.br/ws/
- XSD Schemas disponíveis
- Ambiente de homologação

**Endpoints:**
```
Homologação: https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx
Produção: https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx
```

---

### **2. Rio de Janeiro (RJ)** 🏖️

**Sistema:** Nota Carioca  
**Site:** https://notacarioca.rio.gov.br  
**Protocolo:** SOAP  
**Padrão:** ABRASF 2.01  
**Certificado:** A1 ou A3

**Complexidade:** ⭐⭐⭐ Média-Alta

**Documentação:**
- https://notacarioca.rio.gov.br/contribuinte/
- Manual de integração disponível
- Sandbox para testes

---

### **3. Belo Horizonte (MG)** 🏔️

**Sistema:** BHISS Digital  
**Site:** https://bhissdigital.pbh.gov.br  
**Protocolo:** REST API  
**Padrão:** Próprio (mais moderno)  
**Certificado:** A1 ou A3

**Complexidade:** ⭐⭐ Média (REST é mais simples)

**Documentação:**
- API REST moderna
- Swagger/OpenAPI disponível
- Melhor documentada

---

### **4. Curitiba (PR)** 🌲

**Sistema:** ISS Online  
**Protocolo:** SOAP  
**Padrão:** Próprio  
**Certificado:** A1 ou A3

---

### **5. Brasília (DF)** 🏛️

**Sistema:** NFS-e DF  
**Protocolo:** SOAP  
**Padrão:** ABRASF  
**Certificado:** A1 ou A3

---

## 📋 PADRÕES DE NFS-e NO BRASIL

### **ABRASF (Associação Brasileira das Secretarias de Finanças)**

A maioria das prefeituras segue um dos padrões ABRASF:

- **ABRASF 1.0** - Antigo, poucas cidades ainda usam
- **ABRASF 2.01** - Mais comum (50%+ das cidades)
- **ABRASF 2.03** - Mais recente (São Paulo e outras)
- **ABRASF 2.04** - Novo padrão (em adoção)

### **Padrões Proprietários:**

Algumas grandes cidades criaram seus próprios padrões:
- **Ginfes** - Usado em várias cidades
- **BETHA** - Software muito usado em cidades menores
- **IPM** - Outro sistema comum
- **Próprios** - São Paulo, Campinas, etc.

---

## 💻 IMPLEMENTAÇÃO TÉCNICA

### **Tecnologias Necessárias:**

1. **Certificado Digital A1 ou A3**
   - Custo: R$ 150-300/ano
   - Tipo pessoa jurídica (e-CNPJ)

2. **Biblioteca de XML**
   - Ruby: Nokogiri
   - Geração e parsing de XML

3. **Biblioteca de Assinatura Digital**
   - Ruby: `xml_digital_signature` gem
   - OpenSSL para manipular certificado

4. **Cliente SOAP** (maioria das cidades)
   - Ruby: Savon gem
   - Para consumir Web Services

5. **Cliente REST** (cidades modernas)
   - Ruby: HTTParty ou Faraday
   - Mais simples que SOAP

---

## 🔧 EXEMPLO PRÁTICO - ABRASF 2.03

### **PASSO 1: Instalar Gems**

```ruby
# Gemfile
gem 'savon', '~> 2.14'              # Cliente SOAP
gem 'nokogiri', '~> 1.15'           # XML parsing
gem 'openssl'                        # Certificado digital
```

---

### **PASSO 2: Configurar Certificado**

```ruby
# config/initializers/nfse_config.rb
NFSE_CONFIG = {
  certificate_path: Rails.root.join('config', 'certificates', 'certificado.pfx'),
  certificate_password: ENV['CERTIFICATE_PASSWORD'],
  prefeitura_url: ENV['NFSE_PREFEITURA_URL'],
  ambiente: ENV['NFSE_AMBIENTE'] || 'homologacao', # homologacao ou producao
  inscricao_municipal: ENV['INSCRICAO_MUNICIPAL'],
  cnpj: ENV['CNPJ']
}
```

---

### **PASSO 3: Service para Gerar XML**

```ruby
# app/services/nfse/xml_generator.rb
module Nfse
  class XmlGenerator
    def initialize(invoice)
      @invoice = invoice
      @company = CompanySetting.instance
    end
    
    def generate
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.GerarNfseEnvio(xmlns: "http://www.abrasf.org.br/nfse.xsd") {
          xml.Rps {
            xml.InfDeclaracaoPrestacaoServico {
              # Identificação do RPS
              xml.IdentificacaoRps {
                xml.Numero @invoice.invoice_number
                xml.Serie @invoice.serie
                xml.Tipo 1 # 1=RPS, 2=Nota Fiscal Conjugada
              }
              
              # Data de emissão
              xml.DataEmissao @invoice.issued_at.strftime("%Y-%m-%dT%H:%M:%S")
              
              # Prestador (sua empresa)
              xml.Prestador {
                xml.CpfCnpj {
                  xml.Cnpj @company.cnpj.gsub(/\D/, '')
                }
                xml.InscricaoMunicipal NFSE_CONFIG[:inscricao_municipal]
              }
              
              # Tomador (cliente)
              xml.Tomador {
                xml.IdentificacaoTomador {
                  xml.CpfCnpj {
                    if @invoice.customer_cpf_cnpj.length == 11
                      xml.Cpf @invoice.customer_cpf_cnpj.gsub(/\D/, '')
                    else
                      xml.Cnpj @invoice.customer_cpf_cnpj.gsub(/\D/, '')
                    end
                  }
                }
                xml.RazaoSocial @invoice.customer_name
                xml.Endereco {
                  xml.Endereco @invoice.customer_address
                  xml.Numero "S/N"
                  xml.Bairro "Centro"
                  xml.CodigoMunicipio codigo_municipio(@invoice.customer_city)
                  xml.Uf @invoice.customer_state
                  xml.Cep @invoice.customer_zip_code&.gsub(/\D/, '')
                }
              }
              
              # Serviço prestado
              xml.Servico {
                xml.Valores {
                  xml.ValorServicos format_decimal(@invoice.total_value)
                  xml.ValorDeducoes "0.00"
                  xml.ValorPis format_decimal(@invoice.pis_value)
                  xml.ValorCofins format_decimal(@invoice.cofins_value)
                  xml.ValorInss "0.00"
                  xml.ValorIr "0.00"
                  xml.ValorCsll "0.00"
                  xml.IssRetido 2 # 1=Sim, 2=Não
                  xml.ValorIss format_decimal(@invoice.iss_value)
                  xml.BaseCalculo format_decimal(@invoice.total_value)
                  xml.Aliquota format_decimal(@invoice.iss_rate / 100)
                  xml.ValorLiquidoNfse format_decimal(@invoice.net_value)
                }
                
                xml.ItemListaServico "01.01" # Código do serviço (consultar tabela)
                xml.CodigoCnae "6209100" # CNAE da empresa
                xml.CodigoTributacaoMunicipio "010101" # Código município
                xml.Discriminacao @invoice.service_order.description
                xml.CodigoMunicipio codigo_municipio(@company.city)
              }
            }
          }
        }
      end
      
      builder.to_xml
    end
    
    private
    
    def format_decimal(value)
      format('%.2f', value || 0)
    end
    
    def codigo_municipio(city)
      # Tabela IBGE de municípios
      # São Paulo: 3550308
      # Rio de Janeiro: 3304557
      # Belo Horizonte: 3106200
      # Você precisa de uma tabela completa
      MUNICIPIOS[city] || "0000000"
    end
  end
end
```

---

### **PASSO 4: Assinar XML com Certificado**

```ruby
# app/services/nfse/xml_signer.rb
require 'openssl'
require 'base64'

module Nfse
  class XmlSigner
    def initialize(xml)
      @xml = xml
      @certificate = load_certificate
    end
    
    def sign
      # Carregar XML
      doc = Nokogiri::XML(@xml)
      
      # Calcular digest SHA1 do conteúdo
      canonical_xml = canonicalize(doc)
      digest = OpenSSL::Digest::SHA1.digest(canonical_xml)
      digest_base64 = Base64.strict_encode64(digest)
      
      # Criar assinatura
      signature = create_signature(digest_base64)
      
      # Adicionar assinatura ao XML
      add_signature_to_xml(doc, signature, digest_base64)
      
      doc.to_xml
    end
    
    private
    
    def load_certificate
      pfx_content = File.read(NFSE_CONFIG[:certificate_path])
      pfx = OpenSSL::PKCS12.new(pfx_content, NFSE_CONFIG[:certificate_password])
      {
        cert: pfx.certificate,
        key: pfx.key
      }
    end
    
    def canonicalize(doc)
      # Canonicalização C14N (XML-DSig requirement)
      doc.canonicalize
    end
    
    def create_signature(digest_base64)
      # Assinar com chave privada
      signature_value = @certificate[:key].sign(
        OpenSSL::Digest::SHA1.new, 
        digest_base64
      )
      Base64.strict_encode64(signature_value)
    end
    
    def add_signature_to_xml(doc, signature, digest)
      # Adicionar nó Signature conforme XML-DSig
      # (implementação simplificada - veja spec completa)
      sig_node = Nokogiri::XML::Node.new("Signature", doc)
      sig_node['xmlns'] = "http://www.w3.org/2000/09/xmldsig#"
      
      # SignedInfo
      signed_info = Nokogiri::XML::Node.new("SignedInfo", doc)
      # ... adicionar elementos conforme spec
      
      # SignatureValue
      sig_value = Nokogiri::XML::Node.new("SignatureValue", doc)
      sig_value.content = signature
      
      sig_node.add_child(signed_info)
      sig_node.add_child(sig_value)
      
      doc.root.add_child(sig_node)
    end
  end
end
```

---

### **PASSO 5: Cliente SOAP**

```ruby
# app/services/nfse/soap_client.rb
module Nfse
  class SoapClient
    def initialize
      @client = Savon.client(
        wsdl: NFSE_CONFIG[:prefeitura_url],
        ssl_cert_file: NFSE_CONFIG[:certificate_path],
        ssl_cert_key_file: NFSE_CONFIG[:certificate_path],
        ssl_cert_key_password: NFSE_CONFIG[:certificate_password],
        open_timeout: 10,
        read_timeout: 10,
        log: true,
        log_level: :debug,
        pretty_print_xml: true
      )
    end
    
    def enviar_lote_rps(xml_assinado)
      response = @client.call(
        :gerar_nfse,
        message: {
          'ns1:GerarNfseEnvio' => xml_assinado
        }
      )
      
      parse_response(response)
    end
    
    def consultar_nfse(numero)
      response = @client.call(
        :consultar_nfse_por_rps,
        message: {
          'ns1:ConsultarNfseRpsEnvio' => build_consulta_xml(numero)
        }
      )
      
      parse_response(response)
    end
    
    def cancelar_nfse(numero, motivo)
      response = @client.call(
        :cancelar_nfse,
        message: {
          'ns1:CancelarNfseEnvio' => build_cancelamento_xml(numero, motivo)
        }
      )
      
      parse_response(response)
    end
    
    private
    
    def parse_response(response)
      doc = Nokogiri::XML(response.body.to_s)
      
      # Verificar erros
      erros = doc.xpath('//ListaMensagemRetorno/MensagemRetorno')
      if erros.any?
        raise NfseError, erros.first.text
      end
      
      # Extrair dados da nota fiscal
      {
        numero: doc.xpath('//Numero').text,
        codigo_verificacao: doc.xpath('//CodigoVerificacao').text,
        data_emissao: doc.xpath('//DataEmissao').text,
        xml_completo: doc.to_xml
      }
    end
    
    def build_consulta_xml(numero)
      # Construir XML de consulta
    end
    
    def build_cancelamento_xml(numero, motivo)
      # Construir XML de cancelamento
    end
  end
end
```

---

### **PASSO 6: Service Principal**

```ruby
# app/services/nfse/issuer.rb
module Nfse
  class Issuer
    def self.emit(invoice)
      new(invoice).emit
    end
    
    def initialize(invoice)
      @invoice = invoice
    end
    
    def emit
      # 1. Gerar XML
      xml = XmlGenerator.new(@invoice).generate
      Rails.logger.info "XML gerado: #{xml}"
      
      # 2. Assinar XML
      xml_assinado = XmlSigner.new(xml).sign
      Rails.logger.info "XML assinado"
      
      # 3. Enviar para prefeitura
      client = SoapClient.new
      response = client.enviar_lote_rps(xml_assinado)
      Rails.logger.info "Resposta: #{response}"
      
      # 4. Atualizar invoice com dados oficiais
      @invoice.update!(
        official_number: response[:numero],
        verification_code: response[:codigo_verificacao],
        official_xml: response[:xml_completo],
        status: :issued
      )
      
      # 5. Retornar sucesso
      { success: true, invoice: @invoice }
      
    rescue => e
      Rails.logger.error "Erro ao emitir NFS-e: #{e.message}"
      { success: false, error: e.message }
    end
  end
end
```

---

### **PASSO 7: Controller Action**

```ruby
# app/controllers/invoices_controller.rb
def emit_official
  @invoice = Invoice.find(params[:id])
  
  result = Nfse::Issuer.emit(@invoice)
  
  if result[:success]
    redirect_to @invoice, notice: "NFS-e emitida com sucesso! Número oficial: #{@invoice.official_number}"
  else
    redirect_to @invoice, alert: "Erro ao emitir NFS-e: #{result[:error]}"
  end
end
```

---

## 🗄️ DATABASE - Campos Adicionais

Para API oficial, adicione estes campos ao model Invoice:

```ruby
# Migration
add_column :invoices, :official_number, :string      # Número da prefeitura
add_column :invoices, :verification_code, :string    # Código de verificação
add_column :invoices, :official_xml, :text          # XML completo retornado
add_column :invoices, :rps_number, :string          # Número do RPS
add_column :invoices, :lote_number, :string         # Número do lote
add_column :invoices, :protocol, :string            # Protocolo de envio

add_index :invoices, :official_number
add_index :invoices, :verification_code
```

---

## 📚 RECURSOS E LINKS ÚTEIS

### **Padrão ABRASF:**
- http://www.abrasf.org.br/
- Schemas XSD disponíveis
- Documentação técnica

### **Tabelas de Referência:**
- **CNAE:** https://concla.ibge.gov.br/
- **Códigos de Município (IBGE):** https://www.ibge.gov.br/
- **Lista de Serviços:** Consultar tabela da prefeitura

### **Certificado Digital:**
- **Serasa Experian:** https://certificadodigital.serasaexperian.com.br/
- **Certisign:** https://www.certisign.com.br/
- **Soluti:** https://www.soluti.com.br/

### **Gems Ruby Úteis:**
```ruby
gem 'savon'              # Cliente SOAP
gem 'nokogiri'           # XML parsing
gem 'br_nfe'             # Gem para NF-e/NFS-e (ajuda)
gem 'cpf_cnpj'           # Validação CPF/CNPJ
```

### **Gem BR_NFE (Recomendada):**
- https://github.com/asseinfo/br_nfe
- Facilita MUITO a implementação
- Suporta vários padrões
- Abstrai complexidade

---

## 🎯 EXEMPLO COMPLETO COM GEM BR_NFE

A gem `br_nfe` facilita MUITO a implementação:

```ruby
# Gemfile
gem 'br_nfe'

# Configuração
BrNfe.setup do |config|
  config.certificado_path = Rails.root.join('config', 'certificates', 'certificado.pfx')
  config.certificado_password = ENV['CERTIFICATE_PASSWORD']
end

# Uso
require 'br_nfe/service_invoice'

# Emitir nota
invoice_service = BrNfe::ServiceInvoice.new(
  inscricao_municipal: '12345678',
  cnpj: '12345678000190',
  # ... outros dados
)

nota = BrNfe::Product::Nfse.new(
  numero_rps: @invoice.invoice_number,
  # ... configuração
)

result = invoice_service.emit(nota)

if result.success?
  @invoice.update(official_number: result.numero_nfse)
else
  Rails.logger.error result.error_messages
end
```

**MUITO mais simples que implementar do zero!**

---

## ⚠️ DESAFIOS DA API DIRETA

### **1. Complexidade Técnica** ⭐⭐⭐⭐⭐
- XML assinado digitalmente
- SOAP/Web Services antigos
- Especificações complexas
- Debugging difícil

### **2. Cada Cidade é Diferente**
- Padrões diferentes
- Validações específicas
- Códigos de serviço variam
- Testes em produção

### **3. Certificado Digital**
- Custo: R$ 150-300/ano
- Renovação anual
- Configuração complexa
- Problemas de compatibilidade

### **4. Homologação Demorada**
- Processo burocrático
- Pode levar semanas
- Requisitos específicos
- Testes obrigatórios

### **5. Manutenção**
- APIs mudam
- Novas versões
- Debugging de erros
- Sem suporte oficial

### **6. Tabelas Auxiliares**
- Códigos de serviço
- Códigos CNAE
- Códigos de município
- Mantê-las atualizadas

---

## 💰 ANÁLISE DE CUSTO-BENEFÍCIO

### **Cenário: 100 notas/mês**

#### **Opção 1: API Direta**
- Certificado Digital: R$ 20/mês (R$ 240/ano)
- Desenvolvimento: R$ 0 (você faz)
- Tempo de dev: 40-80 horas
- Manutenção: Você faz
- **Total: R$ 20/mês + seu tempo**

#### **Opção 2: NFE.io**
- Plano: R$ 20/mês (até 100 notas)
- Certificado: R$ 20/mês
- Desenvolvimento: 8-16 horas (API simples)
- Manutenção: Deles
- **Total: R$ 40/mês + menos tempo**

### **Conclusão:**
Se você valoriza seu tempo em R$ 50/hora:
- API Direta: R$ 20/mês + 60h × R$ 50 = **R$ 3.020** (primeiro mês)
- NFE.io: R$ 40/mês + 12h × R$ 50 = **R$ 640** (primeiro mês)

**NFE.io sai MUITO mais barato considerando o tempo!**

---

## 🎓 MINHA RECOMENDAÇÃO FINAL

### **Para 95% dos casos: USE NFE.IO** ⭐⭐⭐⭐⭐

**Por quê?**
1. ✅ API unificada para 5.000+ cidades
2. ✅ Implementação em 2-3 dias
3. ✅ Suporte técnico incluído
4. ✅ Homologação facilitada
5. ✅ Custo baixo (R$ 20-200/mês)
6. ✅ Sem dor de cabeça
7. ✅ Foco no seu negócio, não em burocracia

### **Use API Direta APENAS se:**
- ✅ Atua em **1 única cidade**
- ✅ Tem **conhecimento avançado** em XML/SOAP
- ✅ Tem **muito tempo** disponível (1-2 semanas)
- ✅ Gosta de **desafios técnicos**
- ✅ Quer **economia** absoluta
- ✅ Já tem experiência com integrações fiscais

---

## 📋 ROTEIRO PARA API DIRETA

Se você decidir ir pela API direta:

### **Fase 1: Preparação (1-2 dias)**
1. Comprar certificado digital e-CNPJ
2. Instalar certificado
3. Cadastrar na prefeitura
4. Obter documentação técnica
5. Baixar schemas XSD

### **Fase 2: Desenvolvimento (5-7 dias)**
1. Instalar gems (savon, nokogiri, br_nfe)
2. Implementar geração de XML
3. Implementar assinatura digital
4. Implementar cliente SOAP
5. Criar services principais
6. Testes unitários

### **Fase 3: Homologação (2-4 dias)**
1. Configurar ambiente de testes
2. Enviar notas de teste
3. Validar retornos
4. Corrigir erros
5. Documentar problemas

### **Fase 4: Produção (1 dia)**
1. Configurar ambiente real
2. Emitir primeira nota
3. Validar no site da prefeitura
4. Monitorar logs

**Total: 1-2 semanas de trabalho intenso**

---

## ✅ CHECKLIST DE IMPLEMENTAÇÃO

### **Pré-requisitos:**
- [ ] Certificado digital e-CNPJ comprado
- [ ] Inscrição municipal ativa
- [ ] Documentação da prefeitura obtida
- [ ] Ambiente de homologação configurado

### **Implementação:**
- [ ] Gems instaladas
- [ ] Gerador de XML criado
- [ ] Assinador digital implementado
- [ ] Cliente SOAP/REST criado
- [ ] Services principais prontos
- [ ] Testes criados

### **Homologação:**
- [ ] Nota de teste emitida
- [ ] Validada no site da prefeitura
- [ ] Consulta funcionando
- [ ] Cancelamento funcionando

### **Produção:**
- [ ] Configuração de produção
- [ ] Primeira nota real emitida
- [ ] Monitoramento ativo
- [ ] Backup de XMLs configurado

---

## 🆘 QUANDO PEDIR AJUDA

### **Contrate um especialista se:**
- Nunca trabalhou com XML/SOAP
- Não entende certificado digital
- Prazo é apertado (< 1 mês)
- Não tem tempo para debugar
- Precisa de múltiplas cidades

**Custo típico:**
- Freelancer: R$ 3.000 - R$ 10.000
- Empresa: R$ 10.000 - R$ 30.000

**Ainda assim, NFE.io continua sendo mais barato!**

---

## 🎯 CONCLUSÃO

**Resposta final à sua pergunta:**

> "Para usar API da prefeitura eu preciso de um serviço como o NFE.io?"

**NÃO, você não precisa.** Você pode criar sua própria integração diretamente com a API da prefeitura.

**MAS:**
- É **MUITO** mais complexo
- Leva **muito mais tempo** (1-2 semanas vs 2-3 dias)
- Requer **conhecimento avançado**
- Você fica **sozinho** (sem suporte)
- **Cada cidade é diferente**

**RECOMENDAÇÃO:**
- 🥇 **MELHOR:** Use NFE.io (R$ 20-200/mês)
- 🥈 **BOM:** Use gem BR_NFE (facilita muito)
- 🥉 **HARD MODE:** Implemente do zero com Savon + Nokogiri

**Meu conselho pessoal:**
Use NFE.io e foque no seu produto principal. Os R$ 20-200/mês valem MUITO a paz de espírito!

---

**Desenvolvido com ❤️ para o Sistema de Ordens de Serviço**  
**Ruby on Rails 7.1 💎**
