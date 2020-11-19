import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

const db = admin.firestore();
const fcm = admin.messaging();

export const novaReceita = functions.firestore
    .document('/tratamentos/{id}')
    .onCreate(async snapshot => {
        const receita = snapshot.data();

        const querySnapshot = await db
            .collection('pacientes')
            .doc(receita.pid.toString())
            .collection('tokens')
            .get();
        
        const tokens = querySnapshot.docs.map(snap => snap.id);

        const payload: admin.messaging.MessagingPayload = {
            notification: {
                title: 'Nova receita!',
                body: `${receita.medico} te enviou uma nova lista de medicamentos...`,
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                badge: '1'
            },
            data: {
                'rid': `${receita.id}`
            }
        };

        return fcm.sendToDevice(tokens, payload);
    });

export const retornoTratamento = functions.firestore
    .document('/tratamentos/{id}')
    .onUpdate(async snapshot => {
        const tratamento = snapshot.after.data();
        const retorno = snapshot.after.data();

        if (retorno.estado <= 2.5) {
            const querySnapshot = await db
                .collection('medicos')
                .doc(tratamento.mid.toString())
                .collection('tokens')
                .get();
            
            const tokens = querySnapshot.docs.map(snap => snap.id);
    
            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: 'Paciente mal!',
                    body: `${tratamento.paciente} não está se sentindo bem com o tratamento...`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    badge: '1',
                },
                data: {
                    'rid': `${tratamento.id}`,
                    'pid': `${tratamento.pid}`,
                    'estado': `${retorno.estado}`
                }
            };
    
            return fcm.sendToDevice(tokens, payload);
        }

        if (retorno.estado >= 4.5) {
            const querySnapshot = await db
                .collection('medicos')
                .doc(tratamento.mid.toString())
                .collection('tokens')
                .get();
            
            const tokens = querySnapshot.docs.map(snap => snap.id);

            const payload: admin.messaging.MessagingPayload = {
                notification: {
                    title: 'Melhora do paciente!',
                    body: `${tratamento.paciente} está se sentindo muito bem com o tratamento...`,
                    clickAction: 'FLUTTER_NOTIFICATION_CLICK',
                    badge: '1',
                },
                data: {
                    'rid': `${tratamento.id}`,
                    'pid': `${tratamento.pid}`,
                    'estado': `${retorno.estado}`
                }
            };

            return fcm.sendToDevice(tokens, payload);
        }

        return null;
    });