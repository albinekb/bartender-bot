// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from 'next'

export type Pump = {
  id: string
  name: string
}

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<Pump[]>
) {
  res.status(200).json([
    {
      id: 'X',
      name: 'X',
    },
    {
      id: 'Y',
      name: 'Y',
    },
    {
      id: 'Z',
      name: 'Z'
    },
  ])
}
