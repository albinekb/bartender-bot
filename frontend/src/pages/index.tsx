import { Inter } from 'next/font/google'
import { useState } from 'react'
import { usePumps } from '~/hooks/usePumps'

const inter = Inter({ subsets: ['latin'] })

export default function Home() {
  const pumps = usePumps()
  return (
    <main
      className={`flex min-h-screen flex-row justify-center items-center p-24 space-x-4 ${inter.className}`}
    >
      {pumps.map((pump) => (
        <PumpController key={pump.id} pump={pump} />
      ))}
    </main>
  )
}


function PumpController({ pump }: { pump: any }) {
  const [ml, setMl] = useState(10)
  return <div className="p-4 bg-white rounded flex flex-col justify-center items-center">{pump.name}
    <select className='p-4 px-8 rounded' onChange={(e) => setMl(parseInt(e.target.value))} value={ml}>
      <option value={10}>10ml</option>
      <option value={20}>20ml</option>
      <option value={30}>30ml</option>
      <option value={40}>40ml</option>
      <option value={50}>50ml</option>
      <option value={60}>60ml</option>
      <option value={70}>70ml</option>
      <option value={80}>80ml</option>
      <option value={90}>90ml</option>
      <option value={100}>100ml</option>
    </select>
    <button className='bg-blue-500 text-white p-4 px-8 rounded'>Dispense</button></div>
}