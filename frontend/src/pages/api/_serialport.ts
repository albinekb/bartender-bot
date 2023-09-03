import exitHook from 'exit-hook'
import { SerialPort } from 'serialport'

export const serialport = new SerialPort({ path: '/dev/tty.usbserial-110', baudRate: 9600 })

exitHook(() => {
  serialport.close()
})

serialport.on('data', (data) => {
  console.log('Data:', data.toString())
})
