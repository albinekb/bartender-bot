// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from 'next'
import { serialport } from '../../_serialport'

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<{}>
) {
  const id = req.query.id
  const ml = req.body.ml

  const steps = ml * (2200 / 5)

  switch (id) {
    case 'X':
    case 'Y':
    case 'Z':
    case 'A':
      break
    default:
      res.status(400).json({ error: `Invalid pump id: ${id}` })
      return
  }

  if (typeof req.body.msd === 'number') {
    console.log(`Tweaking MSD to ${req.body.msd}`)
    serialport.write(`MSD${req.body.msd}\r\n`)
    serialport.flush()
    await new Promise((resolve) => setTimeout(resolve, 2500))
  }

  console.log(`Dispensing ${ml}ml from pump ${id} (${steps} steps)`)
  serialport.write(`${id}${steps}\r\n`)
  serialport.flush()
  await new Promise((resolve) => setTimeout(resolve, 2500))

  res.status(200).json({})
}
