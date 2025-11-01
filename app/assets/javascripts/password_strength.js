// Password Strength Indicator
(function() {
  'use strict';
  
  function checkPasswordStrength(password) {
    if (!password) {
      return { score: 0, label: '', color: '', percentage: 0 };
    }
    
    let score = 0;
    let feedback = [];
    
    // Comprimento
    if (password.length >= 6) {
      score += 25;
    } else {
      feedback.push('Mínimo 6 caracteres');
    }
    
    // Letra maiúscula
    if (/[A-Z]/.test(password)) {
      score += 25;
    } else {
      feedback.push('Adicione letra maiúscula');
    }
    
    // Número
    if (/[0-9]/.test(password)) {
      score += 25;
    } else {
      feedback.push('Adicione um número');
    }
    
    // Caractere especial
    if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
      score += 25;
    } else {
      feedback.push('Adicione caractere especial');
    }
    
    // Determinar label e cor
    let label, color;
    if (score === 0) {
      label = 'Muito Fraca';
      color = 'danger';
    } else if (score <= 25) {
      label = 'Fraca';
      color = 'danger';
    } else if (score <= 50) {
      label = 'Média';
      color = 'warning';
    } else if (score <= 75) {
      label = 'Boa';
      color = 'info';
    } else {
      label = 'Forte';
      color = 'success';
    }
    
    return {
      score: score,
      label: label,
      color: color,
      percentage: score,
      feedback: feedback
    };
  }
  
  function updatePasswordStrengthIndicator(inputElement, indicatorElement) {
    const password = inputElement.value;
    const strength = checkPasswordStrength(password);
    
    if (!password) {
      indicatorElement.style.display = 'none';
      return;
    }
    
    indicatorElement.style.display = 'block';
    
    const textElement = indicatorElement.querySelector('.password-strength-text');
    const progressBar = indicatorElement.querySelector('.password-strength-bar');
    
    // Atualizar texto
    textElement.textContent = strength.label;
    textElement.className = 'password-strength-text fw-bold text-' + strength.color;
    
    // Atualizar barra de progresso
    progressBar.style.width = strength.percentage + '%';
    progressBar.setAttribute('aria-valuenow', strength.percentage);
    progressBar.className = 'progress-bar password-strength-bar bg-' + strength.color;
    
    // Adicionar feedback se senha não é forte
    if (strength.score < 100 && strength.feedback.length > 0) {
      const feedbackText = strength.feedback.join(', ');
      if (!textElement.dataset.originalText) {
        textElement.dataset.originalText = textElement.textContent;
      }
      textElement.innerHTML = strength.label + ' <small class="text-muted">(' + feedbackText + ')</small>';
    }
  }
  
  function initPasswordStrengthIndicators() {
    // Encontrar todos os campos de senha que precisam de indicador
    const passwordFields = document.querySelectorAll('input[type="password"][data-strength-indicator]');
    
    passwordFields.forEach(function(field) {
      const indicatorId = field.getAttribute('data-strength-indicator');
      const indicator = document.getElementById(indicatorId);
      
      if (indicator) {
        // Atualizar ao digitar
        field.addEventListener('input', function() {
          updatePasswordStrengthIndicator(field, indicator);
        });
        
        // Atualizar ao colar
        field.addEventListener('paste', function() {
          setTimeout(function() {
            updatePasswordStrengthIndicator(field, indicator);
          }, 100);
        });
        
        // Verificar valor inicial
        if (field.value) {
          updatePasswordStrengthIndicator(field, indicator);
        }
      }
    });
  }
  
  // Inicializar quando DOM estiver pronto
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initPasswordStrengthIndicators);
  } else {
    initPasswordStrengthIndicators();
  }
  
  // Reinicializar com Turbo
  document.addEventListener('turbo:load', initPasswordStrengthIndicators);
})();
