// hooks/useExportReports.ts
import { useCallback } from 'react'
import jsPDF from 'jspdf'
import html2canvas from 'html2canvas'
import ExcelJS from 'exceljs'

export const useExportReports = () => {
  // Função para formatar telefone para exportação
  const formatPhoneForExport = (phone: string): string => {
    if (!phone) return '';
    
    // Remove todos os caracteres especiais e espaços
    let cleanPhone = phone.replace(/[^\d]/g, '');
    
    // Remove código do país se já existir (55 no início)
    if (cleanPhone.startsWith('55') && cleanPhone.length >= 12) {
      cleanPhone = cleanPhone.substring(2);
    }
    
    // Remove o 9 inicial se existir (após o DDD) para números de 11 dígitos
    if (cleanPhone.length === 11 && cleanPhone.charAt(2) === '9') {
      cleanPhone = cleanPhone.substring(0, 2) + cleanPhone.substring(3);
    }
    
    // Garantir que tenha pelo menos 10 dígitos (DDD + número)
    if (cleanPhone.length < 10) {
      return '';
    }
    
    // Adiciona o código do país 55
    return `55${cleanPhone}`;
  };

  // Função para formatar data para exportação (evita problemas de fuso horário)
  const formatDateForExport = (dateString: string): string => {
    if (!dateString) return '';
    
    try {
      // Se a data já está no formato YYYY-MM-DD, converte diretamente sem usar Date
      if (dateString.match(/^\d{4}-\d{2}-\d{2}$/)) {
        const [year, month, day] = dateString.split('-');
        return `${day}/${month}/${year}`;
      }
      
      // Se a data está no formato ISO (YYYY-MM-DDTHH:mm:ss.sssZ), pega apenas a parte da data
      // Isso evita problemas de fuso horário ao converter para Date
      if (dateString.match(/^\d{4}-\d{2}-\d{2}T/)) {
        const datePart = dateString.split('T')[0];
        const [year, month, day] = datePart.split('-');
        return `${day}/${month}/${year}`;
      }
      
      // Para outros formatos, tenta converter mas força o fuso horário local
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return '';
      
      // Usa toLocaleDateString com timezone específico para evitar problemas
      return date.toLocaleDateString('pt-BR', {
        timeZone: 'America/Sao_Paulo',
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    } catch (error) {
      console.error('Erro ao formatar data:', error);
      return '';
    }
  };
  // Exportar para PDF (método antigo - print da tela)
  const exportToPDF = useCallback(async (elementId: string, filename: string = 'relatorio.pdf') => {
    try {
      // Tentando exportar PDF para elemento
      
      const element = document.getElementById(elementId)
      if (!element) {
        // Elemento não encontrado
        throw new Error(`Elemento com ID "${elementId}" não encontrado`)
      }

      // Verificar se o elemento tem conteúdo (tabela com dados)
      const tableRows = element.querySelectorAll('tbody tr')
      if (tableRows.length === 0) {
        // Tabela vazia detectada
        throw new Error('Não é possível gerar um relatório sem dados')
      }

      // Elemento encontrado, gerando canvas
      
      const canvas = await html2canvas(element, {
        scale: 2,
        useCORS: true,
        allowTaint: true,
        backgroundColor: '#ffffff',
        logging: false,
        width: element.scrollWidth,
        height: element.scrollHeight
      })

      // Canvas gerado, criando PDF
      
      const imgData = canvas.toDataURL('image/png')
      const pdf = new jsPDF('p', 'mm', 'a4')
      
      const imgWidth = 210
      const pageHeight = 295
      const imgHeight = (canvas.height * imgWidth) / canvas.width
      let heightLeft = imgHeight

      let position = 0

      pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
      heightLeft -= pageHeight

      while (heightLeft >= 0) {
        position = heightLeft - imgHeight
        pdf.addPage()
        pdf.addImage(imgData, 'PNG', 0, position, imgWidth, imgHeight)
        heightLeft -= pageHeight
      }

      // PDF criado, salvando arquivo
      pdf.save(filename)
      
      // PDF exportado com sucesso
    } catch (error) {
      // Erro ao exportar PDF
      throw new Error(`Erro ao exportar PDF: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }, [])

  // Função auxiliar para criar tabela PDF manualmente
  const createPDFTable = (pdf: jsPDF, headers: string[], data: string[][], startY: number) => {
    const pageWidth = pdf.internal.pageSize.getWidth()
    const pageHeight = pdf.internal.pageSize.getHeight()
    const margin = 5
    const tableWidth = pageWidth - (margin * 2)
    
    // Definir larguras específicas para cada coluna (otimizado para 14 colunas)
    const columnWidths = [
      15, // Pos.
      25, // Nome
      20, // WhatsApp
      18, // Instagram
      18, // Cidade
      15, // Setor
      25, // Nome Cônjuge/Parceiro
      20, // WhatsApp Cônjuge/Parceiro
      18, // Instagram Cônjuge/Parceiro
      18, // Cidade Cônjuge/Parceiro
      15, // Setor Cônjuge/Parceiro
      12, // Contratos
      20, // Indicado por
      16  // Data
    ]
    
    const rowHeight = 7
    let currentY = startY

    // Cabeçalho
    pdf.setFillColor(41, 128, 185)
    pdf.setTextColor(255, 255, 255)
    pdf.setFont('helvetica', 'bold')
    pdf.setFontSize(7)
    
    let currentX = margin
    columnWidths.forEach((width, index) => {
      pdf.rect(currentX, currentY, width, rowHeight, 'F')
      if (headers[index]) {
        const headerText = headers[index].substring(0, 12) // Limitar cabeçalho
        pdf.text(headerText, currentX + 1, currentY + 5)
      }
      currentX += width
    })
    
    currentY += rowHeight

    // Dados
    pdf.setTextColor(0, 0, 0)
    pdf.setFont('helvetica', 'normal')
    pdf.setFontSize(5)

    data.forEach((row, rowIndex) => {
      // Verificar se precisa de nova página
      if (currentY + rowHeight > pageHeight - 20) {
        pdf.addPage()
        currentY = 20
        
        // Repetir cabeçalho na nova página
        pdf.setFillColor(41, 128, 185)
        pdf.setTextColor(255, 255, 255)
        pdf.setFont('helvetica', 'bold')
        pdf.setFontSize(7)
        
        currentX = margin
        columnWidths.forEach((width, index) => {
          pdf.rect(currentX, currentY, width, rowHeight, 'F')
          if (headers[index]) {
            const headerText = headers[index].substring(0, 12)
            pdf.text(headerText, currentX + 1, currentY + 5)
          }
          currentX += width
        })
        
        currentY += rowHeight
        pdf.setTextColor(0, 0, 0)
        pdf.setFont('helvetica', 'normal')
        pdf.setFontSize(5)
      }

      // Linha alternada
      if (rowIndex % 2 === 1) {
        pdf.setFillColor(245, 245, 245)
        currentX = margin
        columnWidths.forEach(width => {
          pdf.rect(currentX, currentY, width, rowHeight, 'F')
          currentX += width
        })
      }

      // Dados da linha
      currentX = margin
      row.forEach((cell, colIndex) => {
        if (colIndex < columnWidths.length) {
          const width = columnWidths[colIndex]
          const maxChars = Math.floor(width / 2.5) // Calcular caracteres baseado na largura
          const cellText = String(cell || '').substring(0, maxChars)
          pdf.text(cellText, currentX + 1, currentY + 5)
          currentX += width
        }
      })

      currentY += rowHeight
    })
  }

  // Criar PDF com layout de cards (6 membros por página - 3x2) otimizado
  const createPDFCards = (pdf: jsPDF, members: Record<string, unknown>[], startY: number) => {
    const pageWidth = pdf.internal.pageSize.getWidth()
    const pageHeight = pdf.internal.pageSize.getHeight()
    const margin = 8
    const cardsPerRow = 3
    const rowsPerPage = 2
    const cardWidth = (pageWidth - (margin * 2) - ((cardsPerRow - 1) * 6)) / cardsPerRow // 3 cards por linha, espaçamento menor
    const cardHeight = (pageHeight - startY - 20 - ((rowsPerPage - 1) * 6)) / rowsPerPage // 2 linhas por página, espaçamento menor
    let currentX = margin
    let currentY = startY

    members.forEach((member, index) => {
      const cardsPerPage = cardsPerRow * rowsPerPage // 6 cards por página
      
      // Verificar se precisa de nova página (6 cards por página: 3x2)
      if (index > 0 && index % cardsPerPage === 0) {
        pdf.addPage()
        currentY = startY
        currentX = margin
      }

      // Verificar se precisa quebrar linha (3 cards por linha)
      if (index > 0 && index % cardsPerRow === 0 && index % cardsPerPage !== 0) {
        currentY += cardHeight + 8
        currentX = margin
      }

      // Desenhar card
      pdf.setFillColor(245, 245, 245)
      pdf.rect(currentX, currentY, cardWidth, cardHeight, 'F')
      pdf.setDrawColor(200, 200, 200)
      pdf.rect(currentX, currentY, cardWidth, cardHeight, 'S')

      // Função para truncar texto se necessário
      const truncateText = (text: string, maxWidth: number, fontSize: number) => {
        const avgCharWidth = fontSize * 0.6 // Estimativa da largura do caractere
        const maxChars = Math.floor(maxWidth / avgCharWidth)
        return text.length > maxChars ? text.substring(0, maxChars - 3) + '...' : text
      }

      // Título do card com posição (sem truncar nomes)
      pdf.setFontSize(9)
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(41, 128, 185)
      pdf.text(`#${member.ranking_position || 'N/A'} - ${String(member.name || '')}`, currentX + 2, currentY + 8)

      // Dados da pessoa principal
      pdf.setFontSize(7)
      pdf.setFont('helvetica', 'normal')
      pdf.setTextColor(0, 0, 0)
      
      let textY = currentY + 15
      pdf.text(`WhatsApp: ${formatPhoneForExport(member.phone as string)}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Instagram: ${String(member.instagram || '')}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Setor-Cidade: ${String(member.sector || '')} - ${String(member.city || '')}`, currentX + 2, textY)
      
      // Dados do parceiro
      textY += 6
      pdf.setFont('helvetica', 'bold')
      pdf.setFontSize(7)
      pdf.text(`Parceiro: ${String(member.couple_name || '')}`, currentX + 2, textY)
      
      pdf.setFont('helvetica', 'normal')
      textY += 4.5
      pdf.text(`WhatsApp: ${formatPhoneForExport(member.couple_phone as string)}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Instagram: ${String(member.couple_instagram || '')}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Setor-Cidade: ${String(member.couple_sector || '')} - ${String(member.couple_city || '')}`, currentX + 2, textY)

      // Informações adicionais
      textY += 6
      pdf.setFontSize(6)
      pdf.setTextColor(100, 100, 100)
      pdf.text(`Contratos: ${member.contracts_completed || '0'} | Por: ${String(member.referrer || '')}`, currentX + 2, textY)

      // Próximo card (3 por linha)
      if ((index + 1) % cardsPerRow === 0) {
        currentX = margin // Volta para o início da linha
      } else {
        currentX += cardWidth + 8 // Próximo card na mesma linha
      }
    })
  }

  // Exportar membros para PDF estruturado (layout de cards)
  const exportMembersToPDF = useCallback((members: Record<string, unknown>[]) => {
    try {
      if (!members || members.length === 0) {
        throw new Error('Não é possível gerar um relatório sem dados')
      }

      // Criar PDF estruturado
      const pdf = new jsPDF('l', 'mm', 'a4') // Landscape
      
      // Título
      pdf.setFontSize(16)
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(0, 0, 0)
      pdf.text('Relatório Completo de Membros', 20, 15)
      
      // Data de geração e total
      pdf.setFontSize(10)
      pdf.setFont('helvetica', 'normal')
      pdf.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')}`, 20, 25)
      pdf.text(`Total: ${members.length} membros`, 200, 25)
      
      // Criar cards
      createPDFCards(pdf, members, 35)

      pdf.save('membros_completo.pdf')
    } catch (error) {
      throw new Error(`Erro ao exportar PDF: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }, [])

  // Criar PDF de amigos com layout de cards (6 por página - 3x2) otimizado
  const createFriendsPDFCards = (pdf: jsPDF, friends: unknown[], startY: number) => {
    const pageWidth = pdf.internal.pageSize.getWidth()
    const pageHeight = pdf.internal.pageSize.getHeight()
    const margin = 8
    const cardsPerRow = 3
    const rowsPerPage = 2
    const cardWidth = (pageWidth - (margin * 2) - ((cardsPerRow - 1) * 6)) / cardsPerRow // 3 cards por linha, espaçamento menor
    const cardHeight = (pageHeight - startY - 20 - ((rowsPerPage - 1) * 6)) / rowsPerPage // 2 linhas por página, espaçamento menor
    let currentX = margin
    let currentY = startY

    friends.forEach((friend, index) => {
      const f = friend as Record<string, unknown>
      const cardsPerPage = cardsPerRow * rowsPerPage // 6 cards por página
      
      // Verificar se precisa de nova página (6 cards por página: 3x2)
      if (index > 0 && index % cardsPerPage === 0) {
        pdf.addPage()
        currentY = startY
        currentX = margin
      }

      // Verificar se precisa quebrar linha (3 cards por linha)
      if (index > 0 && index % cardsPerRow === 0 && index % cardsPerPage !== 0) {
        currentY += cardHeight + 8
        currentX = margin
      }

      // Desenhar card
      pdf.setFillColor(245, 245, 245)
      pdf.rect(currentX, currentY, cardWidth, cardHeight, 'F')
      pdf.setDrawColor(200, 200, 200)
      pdf.rect(currentX, currentY, cardWidth, cardHeight, 'S')

      // Função para truncar texto se necessário
      const truncateText = (text: string, maxWidth: number, fontSize: number) => {
        const avgCharWidth = fontSize * 0.6 // Estimativa da largura do caractere
        const maxChars = Math.floor(maxWidth / avgCharWidth)
        return text.length > maxChars ? text.substring(0, maxChars - 3) + '...' : text
      }

      // Título do card (sem posição)
      pdf.setFontSize(9)
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(41, 128, 185)
      pdf.text(`${String(f.name || '')}`, currentX + 2, currentY + 8)

      // Dados da pessoa principal
      pdf.setFontSize(7)
      pdf.setFont('helvetica', 'normal')
      pdf.setTextColor(0, 0, 0)
      
      let textY = currentY + 15
      pdf.text(`WhatsApp: ${formatPhoneForExport(f.phone as string)}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Instagram: ${String(f.instagram || '')}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Setor-Cidade: ${String(f.sector || '')} - ${String(f.city || '')}`, currentX + 2, textY)
      
      // Dados do parceiro
      textY += 6
      pdf.setFont('helvetica', 'bold')
      pdf.setFontSize(7)
      pdf.text(`Parceiro: ${String(f.couple_name || '')}`, currentX + 2, textY)
      
      pdf.setFont('helvetica', 'normal')
      textY += 4.5
      pdf.text(`WhatsApp: ${formatPhoneForExport(f.couple_phone as string)}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Instagram: ${String(f.couple_instagram || '')}`, currentX + 2, textY)
      textY += 4.5
      pdf.text(`Setor-Cidade: ${String(f.couple_sector || '')} - ${String(f.couple_city || '')}`, currentX + 2, textY)

      // Informações adicionais
      textY += 6
      pdf.setFontSize(6)
      pdf.setTextColor(100, 100, 100)
      pdf.text(`Indicado por: ${String(f.member_name || f.referrer || '')}`, currentX + 2, textY)

      // Próximo card (3 por linha)
      if ((index + 1) % cardsPerRow === 0) {
        currentX = margin // Volta para o início da linha
      } else {
        currentX += cardWidth + 8 // Próximo card na mesma linha
      }
    })
  }

  // Exportar amigos para PDF estruturado (layout de cards)
  const exportFriendsToPDF = useCallback((friends: unknown[]) => {
    try {
      if (!friends || friends.length === 0) {
        throw new Error('Não é possível gerar um relatório sem dados')
      }

      const pdf = new jsPDF('l', 'mm', 'a4') // Landscape
      
      // Título
      pdf.setFontSize(16)
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(0, 0, 0)
      pdf.text('Relatório Completo de Amigos', 20, 15)
      
      // Data de geração e total
      pdf.setFontSize(10)
      pdf.setFont('helvetica', 'normal')
      pdf.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')}`, 20, 25)
      pdf.text(`Total: ${friends.length} amigos`, 200, 25)
      
      // Criar cards
      createFriendsPDFCards(pdf, friends, 35)

      pdf.save('amigos_completo.pdf')
    } catch (error) {
      throw new Error(`Erro ao exportar PDF: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }, [])

  // Exportar dados para Excel
  const exportToExcel = useCallback(async (data: Record<string, unknown>[], filename: string = 'relatorio.xlsx', sheetName: string = 'Relatório') => {
    try {
      // Tentando exportar Excel
      
      if (!data || data.length === 0) {
        throw new Error('Não é possível gerar um relatório sem dados')
      }

      const workbook = new ExcelJS.Workbook();
      
      // Para grandes volumes (>10.000 registros), usar processamento em chunks
      if (data.length > 10000) {
        // Processando grande volume de dados em chunks
        
        const chunkSize = 5000
        const chunks = []
        
        for (let i = 0; i < data.length; i += chunkSize) {
          chunks.push(data.slice(i, i + chunkSize))
        }
        
        chunks.forEach((chunk, index) => {
          const worksheet = workbook.addWorksheet(chunks.length > 1 ? `${sheetName} - Parte ${index + 1}` : sheetName);
          
          // Adicionar cabeçalhos
          if (chunk.length > 0) {
            const headers = Object.keys(chunk[0]);
            worksheet.addRow(headers);
            
            // Estilizar cabeçalhos
            const headerRow = worksheet.getRow(1);
            headerRow.font = { bold: true };
            headerRow.fill = {
              type: 'pattern',
              pattern: 'solid',
              fgColor: { argb: 'FFE0E0E0' }
            };
            
            // Adicionar dados
            chunk.forEach(row => {
              const values = headers.map(header => row[header] || '');
              worksheet.addRow(values);
            });
            
            // Auto-ajustar largura das colunas
            worksheet.columns.forEach(column => {
              column.width = 15;
            });
          }
        });
      } else {
        const worksheet = workbook.addWorksheet(sheetName);
        
        // Adicionar cabeçalhos
        if (data.length > 0) {
          const headers = Object.keys(data[0]);
          worksheet.addRow(headers);
          
          // Estilizar cabeçalhos
          const headerRow = worksheet.getRow(1);
          headerRow.font = { bold: true };
          headerRow.fill = {
            type: 'pattern',
            pattern: 'solid',
            fgColor: { argb: 'FFE0E0E0' }
          };
          
          // Adicionar dados
          data.forEach(row => {
            const values = headers.map(header => row[header] || '');
            worksheet.addRow(values);
          });
          
          // Auto-ajustar largura das colunas
          worksheet.columns.forEach(column => {
            column.width = 15;
          });
        }
      }
      
      // Salvar arquivo
      const buffer = await workbook.xlsx.writeBuffer();
      const blob = new Blob([buffer], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
      const url = window.URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = filename;
      link.click();
      window.URL.revokeObjectURL(url);
      
      // Excel exportado com sucesso
    } catch (error) {
      // Erro ao exportar Excel
      throw new Error(`Erro ao exportar Excel: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }, [])

  // Exportar membros para Excel
  const exportMembersToExcel = useCallback((members: Record<string, unknown>[]) => {
    // Exportando membros com dados completos organizados
    
    const data = members.map(member => ({
      // Posição como primeira coluna
      'Posição': member.ranking_position || 'N/A',
      
      // Dados da Pessoa Principal
      'Nome': member.name,
      'WhatsApp': formatPhoneForExport(member.phone as string),
      'Instagram': member.instagram,
      'Cidade': member.city,
      'Setor': member.sector,
      
      // Dados do Parceiro
      'Nome Parceiro': member.couple_name || '',
      'WhatsApp Parceiro': formatPhoneForExport(member.couple_phone as string),
      'Instagram Parceiro': member.couple_instagram || '',
      'Cidade Parceiro': member.couple_city || '',
      'Setor Parceiro': member.couple_sector || '',
      
      // Informações do Sistema
      'Contratos Completos': member.contracts_completed || 0,
      'Indicado por': member.referrer || '',
      'Data de Cadastro': formatDateForExport(member.registration_date as string)
    }))

    exportToExcel(data, 'membros.xlsx', 'Membros')
  }, [exportToExcel, formatDateForExport])

  // Exportar contratos para Excel
  const exportContractsToExcel = useCallback((contracts: Record<string, unknown>[]) => {
    // Exportando contratos com dados completos organizados
    
    const data = contracts.map(contract => ({
      // Dados da Primeira Pessoa
      'Nome Pessoa 1': contract.couple_name_1,
      'WhatsApp Pessoa 1': formatPhoneForExport(contract.couple_phone_1 as string),
      'Instagram Pessoa 1': contract.couple_instagram_1,
      'Cidade Pessoa 1': contract.couple_city_1 || '',
      'Setor Pessoa 1': contract.couple_sector_1 || '',
      
      // Dados da Segunda Pessoa
      'Nome Pessoa 2': contract.couple_name_2,
      'WhatsApp Pessoa 2': formatPhoneForExport(contract.couple_phone_2 as string),
      'Instagram Pessoa 2': contract.couple_instagram_2,
      'Cidade Pessoa 2': contract.couple_city_2 || '',
      'Setor Pessoa 2': contract.couple_sector_2 || '',
      
      // Informações do Contrato
      'ID Contrato': contract.id,
      'Membro Responsável': (contract.member_data as Record<string, unknown>)?.name || 'N/A',
      'Data do Contrato': contract.contract_date ? new Date(contract.contract_date as string).toLocaleDateString('pt-BR') : '',
      'Data de Conclusão': contract.completion_date ? new Date(contract.completion_date as string).toLocaleDateString('pt-BR') : '',
      'Post Verificado 1': contract.post_verified_1 ? 'Sim' : 'Não',
      'Post Verificado 2': contract.post_verified_2 ? 'Sim' : 'Não'
    }))

    exportToExcel(data, 'contratos.xlsx', 'Contratos')
  }, [exportToExcel])

  // Função auxiliar para criar cards organizados
  const createReportCard = (pdf: jsPDF, title: string, data: Array<{label: string, value: string | number}>, startX: number, startY: number, width: number, height: number) => {
    // Fundo do card
    pdf.setFillColor(248, 249, 250)
    pdf.rect(startX, startY, width, height, 'F')
    
    // Borda do card
    pdf.setDrawColor(226, 232, 240)
    pdf.setLineWidth(0.5)
    pdf.rect(startX, startY, width, height, 'S')
    
    // Título do card
    pdf.setFontSize(11)
    pdf.setFont('helvetica', 'bold')
    pdf.setTextColor(41, 128, 185)
    pdf.text(title, startX + 5, startY + 10)
    
    // Linha separadora
    pdf.setDrawColor(226, 232, 240)
    pdf.line(startX + 5, startY + 15, startX + width - 5, startY + 15)
    
    // Dados do card
    let itemY = startY + 25
    pdf.setFontSize(9)
    pdf.setFont('helvetica', 'normal')
    pdf.setTextColor(0, 0, 0)
    
    data.forEach((item, index) => {
      if (itemY > startY + height - 10) return // Não ultrapassar o card
      
      // Label
      pdf.setFont('helvetica', 'normal')
      pdf.text(item.label, startX + 5, itemY)
      
      // Valor
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(41, 128, 185)
      pdf.text(String(item.value), startX + width - 20, itemY)
      
      pdf.setTextColor(0, 0, 0)
      itemY += 8
    })
  }

  // Função auxiliar para desenhar um card
  const drawCard = (pdf: jsPDF, x: number, y: number, width: number, height: number, title: string, content: string[]) => {
    // Fundo do card
    pdf.setFillColor(248, 249, 250)
    pdf.roundedRect(x, y, width, height, 2, 2, 'F')
    
    // Borda do card
    pdf.setDrawColor(229, 231, 235)
    pdf.setLineWidth(0.3)
    pdf.roundedRect(x, y, width, height, 2, 2, 'S')
    
    // Título do card
    pdf.setFontSize(9)
    pdf.setFont('helvetica', 'bold')
    pdf.setTextColor(55, 65, 81)
    pdf.text(title, x + 5, y + 8)
    
    // Conteúdo do card
    pdf.setFontSize(8)
    pdf.setFont('helvetica', 'normal')
    pdf.setTextColor(75, 85, 99)
    let contentY = y + 14
    content.forEach(line => {
      if (contentY < y + height - 3) { // Evita sair do card
        pdf.text(line, x + 5, contentY)
        contentY += 4
      }
    })
  }

  // Exportar dados do relatório para PDF (formato cards como dashboard)
  const exportReportDataToPDF = useCallback((reportData: Record<string, unknown>, memberStats: Record<string, unknown>, topMembersData?: Array<{member: string, count: number, position: number}>) => {
    try {
      if (!reportData || !memberStats) {
        throw new Error('Não é possível gerar um relatório sem dados')
      }

      const pdf = new jsPDF('p', 'mm', 'a4')
      
      // Título principal
      pdf.setFontSize(18)
      pdf.setFont('helvetica', 'bold')
      pdf.setTextColor(41, 128, 185)
      pdf.text('RELATÓRIO COMPLETO DO SISTEMA', 20, 25)
      
      // Data de geração
      pdf.setFontSize(10)
      pdf.setFont('helvetica', 'normal')
      pdf.setTextColor(100, 100, 100)
      pdf.text(`Gerado em: ${new Date().toLocaleDateString('pt-BR')} às ${new Date().toLocaleTimeString('pt-BR')}`, 20, 35)
      
      let y = 50
      const cardWidth = 75
      const cardHeight = 30
      const cardSpacing = 15
      
      // Primeira linha de cards - Estatísticas Gerais
      drawCard(pdf, 20, y, cardWidth, cardHeight, 'Total de Membros', [
        `${memberStats.total_members || 0} membros cadastrados`
      ])
      
      drawCard(pdf, 20 + cardWidth + cardSpacing, y, cardWidth, cardHeight, 'Membros Verdes', [
        `${memberStats.green_members || 0} membros`,
        `${(((memberStats.green_members as number) || 0) / ((memberStats.total_members as number) || 1) * 100).toFixed(1)}% do total`
      ])
      
      y += cardHeight + 25
      
      // Segunda linha de cards
      drawCard(pdf, 20, y, cardWidth, cardHeight, 'Membros Amarelos', [
        `${memberStats.yellow_members || 0} membros`,
        `${(((memberStats.yellow_members as number) || 0) / ((memberStats.total_members as number) || 1) * 100).toFixed(1)}% do total`
      ])
      
      drawCard(pdf, 20 + cardWidth + cardSpacing, y, cardWidth, cardHeight, 'Membros Vermelhos', [
        `${memberStats.red_members || 0} membros`,
        `${(((memberStats.red_members as number) || 0) / ((memberStats.total_members as number) || 1) * 100).toFixed(1)}% do total`
      ])
      
      y += cardHeight + 25
      
      // Card de Cadastros Recentes
      const registrationsByDay = reportData.registrationsByDay as Array<{ date: string, quantidade: number }> || []
      const recentRegistrations = registrationsByDay.reduce((sum, reg) => sum + reg.quantidade, 0)
      
      drawCard(pdf, 20, y, cardWidth * 2 + cardSpacing, cardHeight, 'Cadastros Recentes (7 dias)', [
        `${recentRegistrations} cadastros nos últimos 7 dias`,
        `Média: ${(recentRegistrations / 7).toFixed(1)} por dia`
      ])
      
      y += cardHeight + 25
      
      // Card de Membros por Cidade (top 3)
      if (reportData.usersByCity) {
        const usersByCity = reportData.usersByCity as Record<string, number>
        const topCities = Object.entries(usersByCity)
          .sort(([, a], [, b]) => b - a)
          .slice(0, 3)
        
        const citiesContent = topCities.map(([city, count]) => 
          `${city}: ${count} membros`
        )
        
        drawCard(pdf, 20, y, cardWidth * 2 + cardSpacing, cardHeight, 'Top 3 Cidades', citiesContent)
        
        y += cardHeight + 25
      }
      
      // Card de Setores por Cidade (top 3)
      if (reportData.sectorsGroupedByCity) {
        const sectorsGroupedByCity = reportData.sectorsGroupedByCity as Record<string, any>
        const topSectors = Object.entries(sectorsGroupedByCity)
          .sort(([, a], [, b]) => b.count - a.count)
          .slice(0, 3)
        
        const sectorsContent = topSectors.map(([city, data]) => 
          `${city}: ${data.count} setores`
        )
        
        drawCard(pdf, 20, y, cardWidth * 2 + cardSpacing, cardHeight, 'Top 3 Setores por Cidade', sectorsContent)
        
        y += cardHeight + 25
      }
      
      // Card de Top 5 Membros
      if (topMembersData && topMembersData.length > 0) {
        const topMembersContent = topMembersData.slice(0, 5).map((member, index) => 
          `${index + 1}º ${member.member}: ${member.count} amigos`
        )
        
        drawCard(pdf, 20, y, cardWidth * 2 + cardSpacing, cardHeight + 10, 'Top 5 - Membros que mais Cadastram', topMembersContent)
        
        y += cardHeight + 30
      }
      
      // Card de Resumo por Status (formato horizontal)
      const verde = (memberStats.green_members as number) || 0
      const amarelo = (memberStats.yellow_members as number) || 0
      const vermelho = (memberStats.red_members as number) || 0
      const total = (memberStats.total_members as number) || 1
      
      drawCard(pdf, 20, y, cardWidth * 2 + cardSpacing, cardHeight, 'Resumo por Status', [
        `Verde: ${verde} (${((verde / total) * 100).toFixed(1)}%)`,
        `Amarelo: ${amarelo} (${((amarelo / total) * 100).toFixed(1)}%)`,
        `Vermelho: ${vermelho} (${((vermelho / total) * 100).toFixed(1)}%)`
      ])
      
      pdf.save('relatorio_completo.pdf')
      
    } catch (error) {
      throw new Error(`Erro ao exportar PDF: ${error instanceof Error ? error.message : 'Erro desconhecido'}`)
    }
  }, [])

  // Exportar amigos para Excel
  const exportFriendsToExcel = useCallback((friends: unknown[]) => {
    // Exportando amigos com dados completos organizados
    
    const data = friends.map(friend => {
      const f = friend as Record<string, unknown>
      return {
        // Dados da Pessoa Principal
        'Nome': f.name,
        'WhatsApp': formatPhoneForExport(f.phone as string),
        'Instagram': f.instagram,
        'Cidade': f.city,
        'Setor': f.sector,
        
        // Dados do Parceiro
        'Nome Parceiro': f.couple_name || '',
        'WhatsApp Parceiro': formatPhoneForExport(f.couple_phone as string),
        'Instagram Parceiro': f.couple_instagram || '',
        'Cidade Parceiro': f.couple_city || '',
        'Setor Parceiro': f.couple_sector || '',
        
        // Informações do Sistema
        'Indicado por': f.member_name || f.referrer || '',
        'Data de Cadastro': formatDateForExport((f.created_at || f.registration_date) as string)
      }
    })

    exportToExcel(data, 'amigos.xlsx', 'Amigos')
  }, [exportToExcel, formatDateForExport])


  return {
    exportToPDF,
    exportToExcel,
    exportMembersToExcel,
    exportContractsToExcel,
    exportReportDataToPDF,
    exportFriendsToExcel,
    exportMembersToPDF,
    exportFriendsToPDF
  }
}
