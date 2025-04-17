// api/generate-quiz.js
const fetch = require('node-fetch');

// Numero di domande da generare (puoi renderlo configurabile)
const NUM_QUESTIONS = 3; // Ridotto a 3 per stabilità
const NUM_OPTIONS = 3;  // 3 opzioni per domanda

module.exports = async (req, res) => {
    const functionStartTime = Date.now();
    console.log(`[${new Date(functionStartTime).toISOString()}] Funzione GenerateQuiz avviata.`);

    // 1. Accetta solo POST
    if (req.method !== 'POST') {
        res.setHeader('Allow', ['POST']);
        return res.status(405).json({ error: `Method ${req.method} Not Allowed` });
    }

    // 2. Recupera chiave API sicura
    const OPENROUTER_API_KEY = process.env.OPENROUTER_API_KEY;
    if (!OPENROUTER_API_KEY) {
        console.error('Errore: OPENROUTER_API_KEY non configurata.');
        return res.status(500).json({ error: 'Internal Server Error: API key missing.' });
    }

    // Quiz di esempio in caso di errore
    const fallbackQuiz = {
        questions: [
            {
                question: "Chi è il protagonista della storia?",
                options: ["Un bambino coraggioso", "Un gatto curioso", "Un drago gentile"],
                correctAnswerIndex: 0
            },
            {
                question: "Dove si svolge principalmente la storia?",
                options: ["In una foresta incantata", "In una città moderna", "Su un'isola deserta"],
                correctAnswerIndex: 1
            },
            {
                question: "Qual è la lezione principale della storia?",
                options: ["L'importanza dell'amicizia", "Il valore del coraggio", "La bellezza della natura"],
                correctAnswerIndex: 2
            }
        ]
    };

    try {
        // 3. Estrai il testo della storia dal corpo della richiesta
        const { storyText, ageRange } = req.body; // Ricevi anche ageRange se inviato
        console.log('Testo ricevuto:', storyText ? `${storyText.substring(0, 100)}...` : 'nessun testo');

        if (!storyText || typeof storyText !== 'string' || storyText.trim() === '') {
            return res.status(400).json({ error: 'Il campo "storyText" è obbligatorio nel corpo della richiesta.' });
        }
        
        // Usa ageRange nel prompt per la difficoltà
        const difficultyContext = ageRange ? `Adatta la difficoltà delle domande e il linguaggio alla fascia d'età ${ageRange}.` : 'Le domande dovrebbero essere semplici.';

        // 4. Costruisci il Prompt per generare il QUIZ
        let quizPrompt = `Sei un esperto creatore di quiz per bambini basati su storie.
${difficultyContext}

Crea un quiz basato sulla seguente storia:
${storyText}

Genera ${NUM_QUESTIONS} domande con ${NUM_OPTIONS} opzioni di risposta ciascuna.
Il formato della risposta deve essere un JSON con questa struttura ESATTA:
{
  "questions": [
    {
      "question": "testo della domanda",
      "options": ["opzione1", "opzione2", "opzione3"],
      "correctAnswerIndex": 0
    }
  ]
}

IMPORTANTE:
1. Le domande devono essere chiare e comprensibili
2. Le opzioni devono essere logiche e pertinenti
3. correctAnswerIndex deve essere l'indice (0, 1 o 2) dell'opzione corretta nell'array
4. Rispondi SOLO con il JSON, senza testo aggiuntivo prima o dopo`;

        try {
            // 5. Chiamata all'API di OpenRouter
            console.log(`[${new Date().toISOString()}] Invio richiesta Quiz a OpenRouter...`);
            const apiStartTime = Date.now();
            
            const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
                    'HTTP-Referer': 'https://github.com/yourusername/your-repo',
                    'X-Title': 'Quiz Generator'
                },
                body: JSON.stringify({
                    model: 'deepseek/deepseek-chat-v3-0324:free', // Modello corretto
                    messages: [{ role: 'user', content: quizPrompt }],
                    temperature: 0.7, // Mantenuta la temperatura originale
                    max_tokens: 1000
                })
            });
            
            const apiEndTime = Date.now();
            console.log(`[${new Date().toISOString()}] Risposta Quiz ricevuta. Status: ${response.status}. Durata: ${apiEndTime - apiStartTime}ms`);

            if (!response.ok) {
                const errorBody = await response.text();
                console.error(`Errore da OpenRouter (Quiz): ${response.status}`, errorBody);
                throw new Error(`API Error (Quiz): ${response.status}`);
            }

            const data = await response.json();
            console.log('Risposta API:', JSON.stringify(data, null, 2).substring(0, 500) + '...');
            
            const generatedContent = data.choices?.[0]?.message?.content;
            if (!generatedContent) {
                throw new Error('Nessun contenuto generato dall\'IA per il quiz.');
            }
            
            console.log('Contenuto generato:', generatedContent.substring(0, 500) + '...');

            // 6. Parsing sicuro della risposta JSON
            let quizData;
            try {
                // Rimuovi eventuali backtick e identificatori di json
                let jsonStr = generatedContent.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
                
                // Cerca di estrarre l'oggetto JSON più esterno
                const jsonMatch = jsonStr.match(/\{[\s\S]*\}/);
                if (jsonMatch) {
                    jsonStr = jsonMatch[0];
                }
                
                console.log('JSON estratto:', jsonStr.substring(0, 500) + '...');
                quizData = JSON.parse(jsonStr);
                
                // Validazione della struttura
                if (!quizData.questions || !Array.isArray(quizData.questions)) {
                    throw new Error('Il JSON non contiene un array "questions" valido');
                }
                
                for (const question of quizData.questions) {
                    if (!question.question || !question.options || typeof question.correctAnswerIndex !== 'number') {
                        throw new Error('Una domanda non ha la struttura corretta');
                    }
                    
                    if (!Array.isArray(question.options) || question.options.length < NUM_OPTIONS) {
                        throw new Error('Le opzioni di una domanda non sono valide');
                    }
                    
                    if (question.correctAnswerIndex < 0 || question.correctAnswerIndex >= question.options.length) {
                        throw new Error('Index della risposta corretta non valido');
                    }
                }
                
                console.log(`Quiz validato con successo (${quizData.questions.length} domande)`);
                
                // 7. Invia il quiz al frontend
                return res.status(200).json(quizData);
                
            } catch (parseError) {
                console.error('Errore nel parsing del JSON:', parseError);
                console.error('Testo che ha causato errore:', generatedContent);
                throw new Error(`Formato risposta quiz non valido: ${parseError.message}`);
            }
            
        } catch (apiError) {
            console.error('Errore chiamata API:', apiError);
            console.log('Utilizzando il quiz di fallback');
            return res.status(200).json(fallbackQuiz);
        }
        
    } catch (error) {
        console.error('Errore durante la generazione del quiz:', error);
        console.log('Utilizzando il quiz di fallback dopo errore generale');
        return res.status(200).json(fallbackQuiz);
    } finally {
        const functionEndTime = Date.now();
        console.log(`[${new Date(functionEndTime).toISOString()}] Funzione GenerateQuiz completata in ${functionEndTime - functionStartTime}ms.`);
    }
};
