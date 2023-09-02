// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from 'next'
import fs from 'node:fs/promises'

const FILE = __dirname + '../../../recipes.json'

type Ingredient = {
  id: string
  ml: number
}

type Recipe = {
  name: string
  ingredients: Ingredient[]
}

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse<Recipe[]>
) {
  switch (req.method) {
    case 'GET': {
      const data = await fs.readFile(FILE, 'utf8')
      res.status(200).json(JSON.parse(data))
      break
    }

    case 'POST': {
      const data = await fs.readFile(FILE, 'utf8')
      const recipes = JSON.parse(data)
      const newRecipe = req.body
      recipes.push(newRecipe)
      await fs.writeFile(FILE, JSON.stringify(recipes))
      res.status(200).json(recipes)
      break
    }
  }
}
